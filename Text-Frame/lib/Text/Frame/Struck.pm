package Text::Frame::Struck;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_string       => \&detect_text_string );
    $frame->add_trigger( decode_html_start_strike => \&start_html_strike  );
    $frame->add_trigger( decode_html_start_s      => \&start_html_strike  );
    $frame->add_trigger( decode_html_end_strike   => \&end_html_strike    );
    $frame->add_trigger( decode_html_end_s        => \&end_html_strike    );
    
    $frame->add_trigger( as_text_struck           => \&as_text            );
    
    $frame->add_trigger( as_html_struck           => \&as_html            );
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    my $links_regexp = qr{
            ^
            
            ( .*? )             # capture everything before the struck text
            
            [-][-]
            (                   # capture the struck text, which cannot
                ( \S )          # begin and end in white space or punctuation
                
                (?:             # (this is optional because you can strike out
                    .*?         # just one character)
                    ( \S )
                )?
            )
            [-][-]
            
            ( .*? )             # capture everything after the struck text
            
            $
        }sx;
    
    if ( $string =~ $links_regexp ) {
        my $before          = $1;
        my $struck          = $2;
        my $start_character = $3;
        my $end_character   = $4;
        my $after           = $5;

        my $markers_by_text = (
                   ( $start_character !~ m{ [ [:punct:] ] }x )
                && ( $end_character   !~ m{ [ [:punct:] ] }x )
            );
        
        return  unless $markers_by_text;
        return(
                $before,
                {
                    type   => 'struck',
                    string => $struck,
                },
                $after,
            );
    }
    
    return;
}


sub start_html_strike {
    my $self = shift;
    
    $self->append_inline_element(
            type     => 'struck',
            contents => [],
        );
}
sub end_html_strike {
    my $self = shift;

    $self->remove_insert_point();
}


sub as_text {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    
    $$block .= "--${text}--";
}
sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    
    $$block .= "<strike>${text}</strike>";
}


1;