package Text::Frame::Quote;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_string  => \&detect_text_string );
    $frame->add_trigger( decode_html_start_q => \&start_html_quote   );
    $frame->add_trigger( decode_html_end_q   => \&end_html_quote     );
    
    $frame->add_trigger( as_text_quote      => \&as_text             );
    
    $frame->add_trigger( as_html_quote      => \&as_html             );
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    my $links_regexp = qr{
        ^
        
        ( .*? )             # capture everything before the quote
        
        ['][']
        (                   # capture the quoted text, which cannot
            ( \S )          # begin and end in white space
            
            (?:             # (this part is optional because you can 
                .*?         #  quote just one character)
                ( \S )
            )??
        )
        ['][']

        ( .*? )             # capture everything after the quote
        
        $
    }sx;
        
    if ( $string =~ $links_regexp ) {
        my $before          = $1;
        my $quoted          = $2;
        my $start_character = $3;
        my $end_character   = $4;
        my $after           = $5;

        # my $markers_by_text = (
        #            ( $start_character !~ m{ [ [:punct:] ] }x )
        #         && ( $end_character   !~ m{ [ [:punct:] ] }x )
        #     );
        # 
        # return  unless $markers_by_text;
        return(
                $before,
                {
                    type   => 'quote',
                    string => $quoted,
                },
                $after,
            );
    }
    
    return;
}


sub start_html_quote {
    my $self = shift;

    $self->append_inline_element(
            type     => 'quote',
            contents => [],
        );
}
sub end_html_quote  {
    my $self    = shift;

    $self->remove_insert_point();
}


sub as_text {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    
    $$block .= "''${text}''";
}


sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    
    $$block .= "<q>${text}</q>";
}


1;