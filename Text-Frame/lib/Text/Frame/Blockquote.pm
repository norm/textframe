package Text::Frame::Blockquote;

use strict;
use warnings;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block         => \&detect_text_block );
    $frame->add_trigger( output_as_text_blockquote => \&output_as_text    );
    $frame->add_trigger( output_as_html_blockquote => \&output_as_html    );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
    my $quote_regexp = qr{
        ^
        [>]                 # quote is a greater-than symbol followed by
        [ ]{3}              # three spaces (to make it a full indent)
    }x;
    
    return( 
              'blockquote',
              $block
          ) if ( $block =~ s{$quote_regexp}{}gm );
    return;
}


sub output_as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '>   ';
    $details->{'prefix'    } .= '>   ';
    $details->{'right'     } -= 4;
}
sub output_as_html {
    my $self    = shift;
    my $details = shift;
    
    push @{ $details->{'start_tags'} }, '<blockquote>';
    push @{ $details->{'end_tags'}   }, '</blockquote>';
}


1;
