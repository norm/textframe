package Text::Frame::Comment;

use strict;
use warnings;

our @plugin_before = qw( Block );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block     => \&detect_ignored_comment  );
    $frame->add_trigger( detect_text_block     => \&detect_included_comment );
    $frame->add_trigger( decode_html_comment   => \&add_html_comment        );
    
    $frame->add_trigger( block_as_text_comment => \&as_text                 );
    
    $frame->add_trigger( block_as_html_comment => \&as_html                 );
}


sub detect_ignored_comment {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    my $context  = shift;
    
    # ignored comments can only exist as the first context
    return unless -1 == $#{ $context };
    
    my $ignored_comment_regexp = qr{
            ^
            [/][*]          # line begins with the comment delimiter
        }sx;
    my $remove_comment_regexp = qr{
            ^
            [/ ]? [*]       # line begins either '/*', ' *' or '*'
            ( .* )
            $
            \n
        }mx;
    
    if ( $block =~ m{$ignored_comment_regexp}x ) {
        $block =~ s{$remove_comment_regexp}{}gm;
        
        return (
                'ignored',
                $block,
            );
    }
    
    return;
}
sub detect_included_comment {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    my $context  = shift;
    
    return if $block =~ m{^\s*$}s;
    
    my $included_comment_regexp = qr{
            ^
            [#] [ ]{3}      # line begins with a hash
        }mx;
    
    if ( $block =~ s{$included_comment_regexp}{}gmx ) {
        return (
                'comment',
                $block,
            );
    }
    return;
}


sub add_html_comment {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $string  = shift;
    
    $string =~ s{
        ^
            [<][!][-][-]
            [ ]?
            
            (.*?)
            
            [ ]?
            [-][-][>]
        $
    }{$1}sx;
    
    if ( defined $details->{'current_block'} ) {
        $self->add_new_block( $details->{'current_block'} );
    }

    my %block = (
            context => [
                'indent',
                'comment',
                'block',
            ],
            metadata => {},
            elements => [
                    {
                        type => 'string',
                        text => $string,
                    },
                ],
        );
    $self->add_new_block( \%block );
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '#   ';
    $details->{'prefix'    } .= '#   ';
    $details->{'right'     } -= 4;
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;
    
    $details->{'no_paragraph'} = 1;
    push @{ $details->{'start_tags'} }, '<!-- ';
    push @{ $details->{'end_tags'}   }, ' -->';
    
}


1;