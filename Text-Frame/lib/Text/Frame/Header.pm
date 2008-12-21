package Text::Frame::Header;

use strict;
use warnings;

our @plugin_before = qw( List );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_block => \&detect_block );
}



sub detect_block {
    my $self  = shift;
    my $block = shift;
    
    my $line_count               = ( $block =~ tr{\n}{} );
    my $ends_without_punctuation = ( $block =~ m{ [a-z0-9] $ }ix );
    my $last_line_only_hyphens   = ( $block =~ m{ \n \s* [\-]+ $ }sx );
    my $is_header  = 0;
    
    # print "BLOCK\n{$block}\n";
    # print "LINES   $line_count\n";
    # print "ENDS    $ends_without_punctuation\n";
    # print "HYPHENS $last_line_only_hyphens\n";
    
    $is_header = 1 if ( $line_count == 0  &&  $ends_without_punctuation );
    $is_header = 1 if ( $line_count >  0  &&  $last_line_only_hyphens );
    
    # print "is_header $is_header\n\n";
    
    return 'header' if ( $is_header );
    return;
}

1;
