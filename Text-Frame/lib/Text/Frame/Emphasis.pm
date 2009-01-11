package Text::Frame::Emphasis;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->set_metadata( 'emphasis', 'use_asterisks', 0 );
    
    $frame->add_trigger( detect_text_string       => \&detect_text_string  );
    $frame->add_trigger( decode_html_start_em     => \&start_html_emphasis );
    $frame->add_trigger( decode_html_end_em       => \&end_html_emphasis   );
    $frame->add_trigger( decode_html_start_strong => \&start_html_emphasis );
    $frame->add_trigger( decode_html_end_strong   => \&end_html_emphasis   );
    
    $frame->add_trigger( as_text_emphasis         => \&as_text             );
    
    $frame->add_trigger( as_html_emphasis         => \&as_html             );
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    my $links_regexp = qr{
            ^
            
            ( .*? )             # capture everything before the emphasis
            
            ( [_*] )            # emphasis is surrounded by either asterisks
                                # or underscores, but the pair must match
            
            (                   # capture the emphasis, which cannot
                ( \S )          # begin and end in white space or punctuation
                
                (?:             # (this is optional because you can emphasise
                    .*?         # just one character)
                    ( \S )
                )??
            )
            \2                  # matching close character
            
            ( .*? )             # capture everything after the emphasis
            
            $
        }sx;
        
    if ( $string =~ $links_regexp ) {
        my $before          = $1;
        my $emphasised      = $3;
        my $start_character = $4;
        my $end_character   = $5;
        my $after           = $6;
        
        my $markers_by_text = (
                   ( $start_character !~ m{ [ [:punct:] ] }x )
                && ( $end_character   !~ m{ [ [:punct:] ] }x )
            );
        
        return  unless $markers_by_text;
        return(
                $before,
                {
                    type   => 'emphasis',
                    string => $emphasised,
                },
                $after,
            );
    }
    
    return;
}


sub start_html_emphasis {
    my $self    = shift;
    my $details = shift;

    my $insert  = $self->get_insert_point();
    my %element = (
            type => 'emphasis',
            contents => [],
        );

    push @{ $insert }, \%element;
    $self->add_insert_point( $element{'contents'} );
}
sub end_html_emphasis  {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;

    $self->remove_insert_point();
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    my $block   = shift;
    my $context = shift;
    
    my $emphasis_level = 0;
    foreach my $type ( @{ $context->{'types'} } ) {
        $emphasis_level++  if 'emphasis' eq $type;
    }
    
    my $text     = $details->{'text'};
    my $emphasis = ( 2 == $emphasis_level ) 
                       ? q(*) 
                       : q(_);
    
    $$block .= "${emphasis}${text}${emphasis}";
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $block   = shift;
    my $context = shift;

    my $emphasis_level = 0;
    foreach my $type ( @{ $context->{'types'} } ) {
        $emphasis_level++  if 'emphasis' eq $type;
    }

    my $text    = $details->{'text'};
    my $element = ( 2 == $emphasis_level ) 
                       ? 'strong'
                       : 'em';
    
    $$block .= "<${element}>$text</${element}>";
}


1;
