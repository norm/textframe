package Text::Frame::Indent;

use strict;
use warnings;

use utf8;

our @plugin_before = qw( * );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block    => \&detect_text_block );
    
    $frame->add_trigger( block_as_text_indent => \&as_text           );
    
    $frame->add_trigger( block_as_html_indent => \&as_html           );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
    my $find_indent_regexp = qr{
            ^
            [ ]{4}          # exactly four spaces
        }sx;
    my $remove_indents_regexp = qr{
            ^
            [ ]{4}          # exactly four spaces
        }mx;
    
    if ( $block =~ $find_indent_regexp ) {
        $block =~ s{$remove_indents_regexp}{}gmx;
        
        return( 
                'indent',
                $block
            );
    }
    
    return;
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '    ';
    $details->{'prefix'    } .= '    ';
    $details->{'right'     } -= 4;
}


sub as_html {
    my $self    = shift;
    my $details = shift;

    $details->{'indent'}++;
}


1;