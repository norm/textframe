package Text::Frame::List;

use strict;
use warnings;

use Data::Dumper;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_block => \&detect_block );
}



sub detect_block {
    my $self   = shift;
    my $block  = shift;
    my $blocks = shift;
    
    # find the first line's indent, of the form:
    my $first_indent_regexp = qr{ 
        ^ 
        ( 
            \s*         # optional leading whitespace
            [*o.-]      # an asterisk, letter o, period or hyphen
            \s+         # spaces
        )
    }sx;
    
    if ( $block =~ $first_indent_regexp ) {
        my $first_line_indent = $1;
        my $indent_length     = length( $first_line_indent );
        my $empty_indent      = q( ) x $indent_length;
        
        my $following_indent_regexp = qr{
            \n
            (?:
                $first_line_indent
                |
                $empty_indent
            )
        }mx;
        
        print "FIRST LINE $first_line_indent\n";
        print "LENGTH     $indent_length\n";
        print "\n";

        return 'list';
    }
    
    return;
}


1;
