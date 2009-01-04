package Text::Frame::Number;

use strict;
use warnings;

use utf8;

use Readonly;
    Readonly my $CATEGORY   => 'number';



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block    => \&detect_text_block );
    
    $frame->add_trigger( start_text_document  => \&reset_count       );
    $frame->add_trigger( block_as_text_number => \&as_text           );
    $frame->add_trigger( block_as_text_block  => \&check_is_list     );
    $frame->add_trigger( format_block_text    => \&test_text_block   );
    
    $frame->add_trigger( start_html_document  => \&reset_count       );
    $frame->add_trigger( block_as_html_indent => \&choose_list       );
    $frame->add_trigger( block_as_html_number => \&as_html           );
    $frame->add_trigger( block_as_html_block  => \&check_is_list     );
    $frame->add_trigger( format_block_html    => \&test_html_block   );
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
                (           # capture the number for later, which is...
                    [#]     # either a hash...
                    |
                    \d+     # or a number
                )
                [.]         # followed by a period
                \s+         # followed by at least one space
            )
        }sx;
    
    if ( $block =~ $first_indent_regexp ) {
        my $first_line_indent = $1;
        my $list_number       = $2;
        my $indent_length     = length( $first_line_indent );
        
        # add the value as a metadata hint
        $metadata->{'list_number'} = $list_number;
        
        # preserve the individual characters for the indent regexp
           $first_line_indent =~ s{ (.) }{\[$1\]}gx;
        my $empty_indent       = '[ ]' x 4;

        # list items cannot be headers
        $metadata->{'no_header'} = 1;
        
        # remove the number marker and indentation
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
                'number',
                $block
            );
    }
    
    return;
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    # the right-column value is a good indicator of which list we are in
    my $right_column = $details->{'right'};
    my $list_number  = "list_${right_column}";

    check_count( $self, $list_number );
    
    my $previous = $self->get_metadata( $CATEGORY, 'current_list' )
                || $right_column;
    $self->set_metadata( $CATEGORY, 'previous_list', $previous );
    $self->set_metadata( $CATEGORY, 'current_list',  $right_column );
    
    my $previous_number = $self->get_metadata( $CATEGORY, $list_number );
    my $current_number  = $details->{'metadata'}{'list_number'} || 1;
    
    if ( $previous_number ) {
        # only the very first item in the list can be significant,
        # so for any existing list, we just increment the value
        $current_number = $previous_number + 1;        
    }
    else {
        if ( q(#) eq $current_number ) {
            $current_number = $previous_number + 1;        
        }
    }
    $self->set_metadata( $CATEGORY, $list_number, $current_number );

    # a space must always follow the number, even when 4 chars long
    my $first_line      = '#.  ';
       $current_number .= '. ';
    substr( $first_line, 0, length $current_number, $current_number );
    
    $details->{'first_line'} .= $first_line;
    $details->{'prefix'    } .= '    ';
    $details->{'right'     } -= 4;
}
sub as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;
    
    # the value to use is set from the indent values in choose_list()
    my $list_number = $details->{'list_number'} || 1;
    check_count( $self, $list_number );

    my $previous = $self->get_metadata( $CATEGORY, 'current_list' )
                || $list_number;
    $self->set_metadata( $CATEGORY, 'previous_list', $previous );
    $self->set_metadata( $CATEGORY, 'current_list',  $list_number );
    
    my $previous_number = $self->get_metadata( $CATEGORY, $list_number );
    my $current_number  = $details->{'metadata'}{'list_number'} || 1;
    my $start_attribute = '';
    
    if ( $previous_number ) {
        # only the very first item in the list can be significant,
        # so for any existing list, we just increment the value
        $current_number = $previous_number + 1;        
    }
    else {
        if ( q(#) eq $current_number ) {
            $current_number = $previous_number + 1;        
        }
        if ( $current_number > 1 ) {
            $start_attribute = " start='${current_number}'";
        }
    }
    $self->set_metadata( $CATEGORY, $list_number, $current_number );
    
    my $matches_next  = $count;
    my $next_has_list = 0;
    my $next_indent   = 0;
    
    # check how the next block compares to this block for various tests
    my $highest_count = ( $#{ $next->{'context'} } > $count )
                            ? $#{ $next->{'context'} }
                            : $count;
    foreach my $slice ( 0..$highest_count ) {
        my $this_slice = ${ $block->{'context'} }[$slice];
        my $next_slice = ${  $next->{'context'} }[$slice];
        
        if ( $slice < $count ) {
            $matches_next-- 
                if    ( !defined $this_slice || !defined $next_slice )
                   || $this_slice ne $next_slice;
        }
        
        if ( defined $next_slice ) {
            $next_indent++      if 'indent' eq $next_slice;
            $next_has_list = 1  if 'number' eq $next_slice;
        }
    }
    
    my $indent          = $details->{'indent'} || 1;
    my $text_indent     = q(  ) x ( $indent - 1 );
    my $backdent        = $matches_next - $count;
    my $start_list      = 0;
    my $stop_lists      = 0;
    my $previous_indent = $self->get_metadata( $CATEGORY, 'previous' ) || 0;
    my $list_indent     = $self->get_metadata( $CATEGORY, 'list'     ) || 0;

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
             "${text_indent}<ol${start_attribute}>\n";
    }
    
    if ( $stop_lists ) {
        # when you are closing _all_ lists, don't end up with an extra </li>
        my $skip_first_closer = ( $list_indent == $stop_lists );
        
        while ( $stop_lists ) {
            push @{ $details->{'end_tags'} }, 
                 "\n${text_indent}</li>" 
                    unless $skip_first_closer;
    
            push @{ $details->{'end_tags'} }, 
                 "\n${text_indent}</ol>";

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
        push @{ $details->{'end_tags'} }, 
             "</li>";
    }
    
    $self->set_metadata( $CATEGORY, 'previous', $previous_indent );
    $self->set_metadata( $CATEGORY, 'list',     $list_indent );
}


sub choose_list {
    my $self    = shift;
    my $details = shift;
    
    $details->{'list_number'}++;
}
sub check_count {
    my $self        = shift;
    my $list_number = shift;
    
    my $value = $self->get_metadata( $CATEGORY, $list_number );    
    if ( !defined $value ) {
        $self->set_metadata( $CATEGORY, $list_number, 0 );
    }
}
sub reset_count {
    my $self = shift;
    
    $self->reset_metadata_category( $CATEGORY );
}
sub test_text_block {
    my $self    = shift;
    my $details = shift;
    
    my $previous = $self->get_metadata( $CATEGORY, 'previous_list' ) || 0;
    my $current  = $self->get_metadata( $CATEGORY, 'current_list'  ) || 0;
    
    if ( $current > $previous ) {
        $self->set_metadata( $CATEGORY, "list_${previous}", 0 );
    }
}
sub test_html_block {
    my $self = shift;
    my $details = shift;
    
    my $previous = $self->get_metadata( $CATEGORY, 'previous_list' ) || 0;
    my $current  = $self->get_metadata( $CATEGORY, 'current_list'  ) || 0;

    if ( $current < $previous ) {
        $self->set_metadata( $CATEGORY, $previous, 0 );
    }
}
sub check_is_list {
    my $self = shift;
    my $details = shift;
    
    if ( !defined $details->{'metadata'}{'list_number'} ) {
        reset_count( $self );
    }
}

1;
