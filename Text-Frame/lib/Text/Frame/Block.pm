package Text::Frame::Block;

use strict;
use warnings;

our @plugin_after = qw( * );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_block => \&detect_block );
}



sub detect_block {
    my $self = shift;
    my $block = shift;
    
    return 'block';
}

1;