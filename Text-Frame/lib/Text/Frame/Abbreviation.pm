package Text::Frame::Abbreviation;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_string     => \&detect_text_string );

    $frame->add_trigger( decode_html_start_abbr => \&start_html_abbr    );
    $frame->add_trigger( decode_html_end_abbr   => \&end_html_abbr      );
    
    $frame->add_trigger( as_text_abbreviation   => \&as_text            );
    $frame->add_trigger( as_html_abbreviation   => \&as_html            );


    # $frame->add_trigger( decode_html_start_strong => \&start_html_emphasis );
    # $frame->add_trigger( decode_html_end_strong   => \&end_html_emphasis   );
    # 
    # 
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    my $abbr_regexp = qr{
            ^
            
            ( .*? )             # capture everything before the abbreviation
            
            ( [[:upper:]\d]+ )  # initialisms and acronyms are all-caps
            
            \s+
            
            [(]                 # and followed by an expansion in braces             
            ( .*? )
            [)]
            
            ( .*? )             # capture everything after the abbreviation
            
            $
        }sx;
        
    if ( $string =~ $abbr_regexp ) {
        my $before          = $1;
        my $abbreviation    = $2;
        my $expansion       = $3;
        my $after           = $4;
        
        return(
                $before,
                {
                    type   => 'abbreviation',
                    string => $abbreviation,
                    title  => $expansion,
                },
                $after,
            );
    }
    
    return;
}


sub start_html_abbr {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;
    my @attr    = @_;
    
    my $title;
    foreach my $attribute ( @attr ) {
        foreach my $key ( keys %{ $attribute } ) {
            if ( 'title' eq $key ) {
                $title = $attribute->{ $key };
            }
        }
    }
    
    $self->append_inline_element(
            type     => 'abbreviation',
            contents => [],
            title    => $title,
        );
}
sub end_html_abbr  {
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
    
    my $text  = $details->{'text'};
    my $title = $details->{'title'};
    
    $$block .= "${text} (${title})";
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $block   = shift;
    my $context = shift;

    my $text  = $details->{'text'};
    my $title = $details->{'title'};
    
    $$block .= "<abbr title='${title}'>$text</abbr>";
}


1;
