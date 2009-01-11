package Text::Frame::Bullet;

use strict;
use warnings;

use utf8;

our @plugin_before = qw( Block );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block    => \&detect_text_block    );
    $frame->add_trigger( decode_html_start_ul => \&start_html_list      );
    $frame->add_trigger( decode_html_end_ul   => \&end_html_list        );
    $frame->add_trigger( decode_html_start_li => \&start_html_list_item );
    $frame->add_trigger( decode_html_end_li   => \&end_html_list_item   );
    
    $frame->add_trigger( block_as_text_bullet => \&as_text              );
    
    $frame->add_trigger( block_as_html_bullet => \&as_html              );
}


sub detect_text_block {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    
    # find the first line's indent, of the form:
    my $first_indent_regexp = qr{ 
            ^ 
            ( 
                [*o.-]      # an asterisk, letter o, period or hyphen
                \s+         # spaces
            )
        }sx;
    
    if ( $block =~ $first_indent_regexp ) {
        my $first_line_indent  = $1;
        my $indent_length      = length( $first_line_indent );
        
        # preserve the individual characters for the indent regexp
           $first_line_indent =~ s{ (.) }{\[$1\]}gx;
        my $empty_indent       = '[ ]' x 4;
        
        # list items cannot be headers
        $metadata->{'no_header'} = 1;
        
        # remove the bullet marker and indentation
        $block =~ s{
                (                           # capture the start of the line
                    \n                      # (either a newline or the 
                    |                       # start-string anchor)
                    ^
                )
                (?:                         # match either nothing or
                    $first_line_indent      # the first line's indent
                    |
                    $empty_indent
                )
            }{$1}gmx;
        
        return( 
                'bullet',
                $block
            );
    }
    
    return;
}


sub start_html_list {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;
    
    $self->add_new_html_block( $details );
    
    push @{ $details->{'list_type'} }, 'bullet';
    $details->{'in_list'}++;
}
sub end_html_list {
    my $self    = shift;
    my $details = shift;

    $details->{'in_list'}--;
    pop @{ $details->{'list_type'} };
}
sub start_html_list_item {
    my $self    = shift;
    my $details = shift;
    
    my $types = $details->{'list_type'};
    my $type  = $types->[ $#$types ];
    
    if ( 'bullet' eq $type ) {
        $self->add_new_html_block( $details );
        
        my %block = (
                context => [
                    'bullet',
                    'block',
                ],
                metadata => {},
                elements => [],
            );
        
        my $indent = $details->{'in_list'};
        while ( $indent > 0 ) {
            unshift @{ $block{'context'} }, 'indent';
            $indent--;
        }

        $details->{'current_block'} = \%block;
        $self->add_insert_point( $details->{'current_block'}{'elements'} );
    }
}
sub end_html_list_item {
    my $self    = shift;
    my $details = shift;
    
    $self->add_new_html_block( $details );
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '*   ';
    $details->{'prefix'    } .= '    ';
    $details->{'right'     } -= 4;
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;
    
    my $matches_next  = $count;
    my $next_has_list = 0;
    my $next_indent   = 0;

    # check how the next block compares to this block for various tests
    my $highest_count = ( $#{ $next->{'context'} } > $count )
                            ? $#{ $next->{'context'} }
                            : $count;
    foreach my $slice ( 0 .. $highest_count ) {
        my $this_slice = ${ $block->{'context'} }[$slice];
        my $next_slice = ${  $next->{'context'} }[$slice];
        
        if ( $slice < $count ) {
            $matches_next-- 
                if    ( !defined $this_slice || !defined $next_slice )
                   || $this_slice ne $next_slice;
        }
        
        if ( defined $next_slice ) {
            $next_indent++      if 'indent' eq $next_slice;
            $next_has_list = 1  if 'bullet' eq $next_slice;
        }
    }
    
    my $indent          = $details->{'indent'} || 1;
    my $text_indent     = q(  ) x ( $indent - 1 );
    my $backdent        = $matches_next - $count;
    my $start_list      = 0;
    my $stop_lists      = 0;
    my $previous_indent = $self->get_metadata( 'bullet', 'previous' ) || 0;
    my $list_indent     = $self->get_metadata( 'bullet', 'list'     ) || 0;

    # determine whether to start a list, and how many lists to close (if any)
    $start_list = 1                     if ( $matches_next > $list_indent );
    $start_list = 1                     if ( $previous_indent < $indent   );
    $stop_lists = ( $backdent * -1 );
    $stop_lists = $indent               if ( !$next_has_list );

    # reset previous_indent for reference (it can be modified after this)
    $previous_indent = $indent;
    
    if ( $start_list ) {
        $list_indent++;
        push @{ $details->{'start_tags'} }, 
             "${text_indent}<ul>\n";
    }
    
    if ( $stop_lists ) {
        # when you are closing _all_ lists, don't end up with an extra </li>
        my $skip_first_closer = ( $list_indent == $stop_lists );
        
        while ( $stop_lists ) {
            push @{ $details->{'end_tags'} }, 
                 "\n${text_indent}</li>" 
                    unless $skip_first_closer;
    
            push @{ $details->{'end_tags'} }, 
                 "\n${text_indent}</ul>";

            $stop_lists--;
            $list_indent--;
            $previous_indent--;
            $skip_first_closer = 0;
        }
    }
    
    # open the item (always applicable, because you are _in_ an item)
    push @{ $details->{'start_tags'} }, 
         "${text_indent}  <li>";
    
    # close the item, unless you're creating a sublist on the next item
    if ( $next_indent <= $indent  ||  !$next_has_list ) {
        push @{ $details->{'end_tags'}   }, 
             "</li>";
    }
    
    $self->set_metadata( 'bullet', 'previous', $previous_indent );
    $self->set_metadata( 'bullet', 'list',     $list_indent );
}


1;
