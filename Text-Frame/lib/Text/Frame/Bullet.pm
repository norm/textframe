package Text::Frame::Bullet;

use strict;
use warnings;

my $list_indent     = 0;
my $previous_indent = 0;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block     => \&detect_text_block  );
    $frame->add_trigger( output_as_text_bullet => \&output_as_text     );
    $frame->add_trigger( output_as_html_bullet => \&output_as_html     );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
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
        my $empty_indent       = '[ ]' x $indent_length;

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


sub output_as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'first_line'} .= '*   ';
    $details->{'prefix'    } .= '    ';
    $details->{'right'     } -= 4;
}
sub output_as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;
    
    # determine if the next block matches this in terms of either 
    # being a list, or having the same list indentation
    my @this_slice   = @{ $block->{'context'} }[0..$count-1];
    my @next_slice   = @{ $next->{'context'} }[0..$count-1];    
    my $matches_next = $count;
    foreach my $slice ( 0..$count-1 ) {
        if ( defined $this_slice[$slice]  &&  defined $next_slice[$slice] ) {
            $matches_next--  if $this_slice[$slice] ne $next_slice[$slice];
        }
        else {
            $matches_next--;
        }
    }
    
    my $indent      = $details->{'indent'};
    my $backdent    = $matches_next - $count;
    my $start_list  = 0;
    my $stop_lists  = 0;
    
    $start_list = 1  if ( $matches_next > $list_indent );
    $start_list = 1  if ( $previous_indent < $indent   );
    $stop_lists = ( $backdent * -1 );
    
    my $next_has_list = 0;
    foreach my $item ( @{ $next->{'context'} } ) {
        $next_has_list = 1  if 'bullet' eq $item;
    }
    
    $previous_indent = $indent;
    
    if ( $start_list ) {
        push @{ $details->{'start_tags'} }, "<ul>\n";
        $list_indent++;
    }
    if ( $stop_lists ) {
        while ( $stop_lists ) {
            push @{ $details->{'end_tags'} }, "</ul>\n";
            $stop_lists--;
            $list_indent--;
        }
    }
    if ( !$next_has_list ) {
        # is this still needed, or does stop_lists cover this now?
        while ( $list_indent > 0 ) {
            push @{ $details->{'end_tags'} }, "</ul>\n";
            $list_indent--;
            $previous_indent = 0;
        }
    }
    
    push @{ $details->{'start_tags'} }, '<li>';
    push @{ $details->{'end_tags'}   }, '</li>';
}


1;
