package Text::Frame::Indent;

use strict;
use warnings;

our @plugin_before = qw( * );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block     => \&detect_text_block );
    $frame->add_trigger( output_as_text_indent => \&output_as_text    );
    $frame->add_trigger( output_as_html_indent => \&output_as_html    );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
    my $find_indent_regexp = qr{
        ^
        (
            [ ]{4}
        )
    }x;
    
    if ( $block =~ $find_indent_regexp ) {
        # replace all occurences of the indent across the block
        $block =~ s{ ^ [ ]{4} }{}gmx;

        return( 
                'indent',
                $block
            );
    }
    return;
}


sub output_as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '    ';
    $details->{'prefix'    } .= '    ';
    $details->{'right'     } -= 4;
}
sub output_as_html {
    my $self    = shift;
    my $details = shift;

    $details->{'indent'}++;
}


1;