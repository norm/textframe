package Text::Frame::Block;

use strict;
use warnings;

use utf8;

use Text::Autoformat;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block   => \&detect_text_block    );
    $frame->add_trigger( decode_html_start_p => \&start_html_paragraph );
    $frame->add_trigger( decode_html_end_p   => \&end_html_paragraph   );
    
    $frame->add_trigger( block_as_text_block => \&as_text              );
    
    $frame->add_trigger( block_as_html_block => \&as_html              );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
    # if nothing else, a block is always a block
    return(
              'block',
              $block
          );
}


sub start_html_paragraph {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;

    if ( defined $details->{'current_block'} ) {
        $self->add_new_block( $details->{'current_block'} );
    }

    my %block = (
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [],
        );

    $details->{'current_block'} = \%block;
    $self->add_insert_point( $details->{'current_block'}{'elements'} );
}
sub end_html_paragraph {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;
    
    if ( defined $details->{'current_block'} ) {
        $self->add_new_block( $details->{'current_block'} );
        delete $details->{'current_block'};
    }
}

sub as_text {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;

    my $is_paragraph  = 1;
    my $is_blockquote = defined $details->{'blockquote_depth'};
    
    foreach my $context ( @{ $block->{'context'} } ) {
        $is_paragraph = 0  if  'block' ne $context 
                           && 'indent' ne $context;
    }
    
    if ( $is_paragraph ) {
        my $indent = $is_blockquote 
                         ? q(    ) 
                         : q(        );
        
        $details->{'first_line'} = $indent;
        $details->{'prefix'    } = $indent;
        $details->{'right'     } = $details->{'original_right'} - 8;
    }
    
    my $text  = $details->{'text'};
    
    if ( !defined $details->{'formatted'} ) {
        $text =~ s{[\s\n]+}{ }gs;
        $text  = autoformat 
                    $text,
                    { 
                        left  => $details->{'left'} || 0, 
                        right => $details->{'right'} || 78,
                    };
    }
    
    # remove the extra blank line at the end
    $text =~ s{ \n\n $ }{}sx;
    
    $details->{'text'} = $text;
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;

    # remove unnecessary whitespace
    if ( !defined $details->{'formatted'} ) {
        if ( defined $details->{'text'} ) {
            $details->{'text'}=~ s{ [\s\n]+         }{ }gsx;
            $details->{'text'}=~ s{^ \s* (.*?) \s* $}{$1}gsx;
        }
    }
    
    if ( !$details->{'no_paragraph'} ) {
        push @{ $details->{'start_tags'} }, '<p>';
        push @{ $details->{'end_tags'}   }, '</p>';
    }
}


1;
