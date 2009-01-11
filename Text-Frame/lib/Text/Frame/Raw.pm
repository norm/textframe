package Text::Frame::Raw;

use strict;
use warnings;

use utf8;

use Readonly;

Readonly my $CATEGORY => 'raw';

our @plugin_before = qw( Block );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block   => \&detect_block_raw  );
    $frame->add_trigger( detect_text_string  => \&detect_inline_raw );
    # NB. there is no way of detecting "raw" HTML inside HTML
    # documents, so there are no HTML imports for this module
    
    $frame->add_trigger( start_text_document => \&reset_count       );
    $frame->add_trigger( block_as_text_raw   => \&block_as_text     );
    $frame->add_trigger( as_text_raw         => \&as_text           );
    
    $frame->add_trigger( start_html_document => \&reset_count       );
    $frame->add_trigger( block_as_html_raw   => \&block_as_html     );
    $frame->add_trigger( as_html_raw         => \&as_html           );
}


sub detect_block_raw {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    
    my $raw_block_regexp = qr{
            ^
            [|] [ ]{3}          # starts with a vertical bar
        }mx;
    
    if ( $block =~ s{$raw_block_regexp}{}gm ) {
        my $count = $self->get_metadata( $CATEGORY, 'current_block' ) || 1;
        
        # store the raw block away, otherwise it will be reformatted
        $self->set_metadata( $CATEGORY, $count, $block );
        
        return (
                'raw',
                q(),
            );
    }
    
    return;
}
sub detect_inline_raw {
    my $self   = shift;
    my $string = shift;
    
    my $links_regexp = qr{
            ^
            ( .*? )         # capture everything before the raw text
            
            [|]
            (                   # capture the raw text, which cannot
                \S              # begin or end in white space
                
                (?:             # (this is optional because you can mark just
                    .*?         # one character as being raw)
                    \S
                )??
            )
            [|]
            
            ( .*? )         # capture everything after
            $
        }sx;
        
    if ( $string =~ $links_regexp ) {
        my $before = $1;
        my $raw    = $2;
        my $after  = $3;
        
        return(
                $before,
                {
                    type => 'raw',
                    text => $raw,
                },
                $after,
            );
    }
    
    return;
}


sub as_text {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    
    $$block .= "|${text}|";
}
sub block_as_text {
    my $self    = shift;
    my $details = shift;
    
    my $count     = $self->get_metadata( $CATEGORY, 'current_block' );
    my $raw_block = $self->get_metadata( $CATEGORY, $count          );
    
    $details->{'first_line'} .= q(|   );
    $details->{'prefix'    } .= q(|   );
    $details->{'right'     } -= 4;
    $details->{'text'      }  = $raw_block;
}


sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    $$block .= $item->{'text'};
}
sub block_as_html {
    my $self        = shift;
    my $details     = shift;
    
    my $count     = $self->get_metadata( $CATEGORY, 'current_block' );
    my $raw_block = $self->get_metadata( $CATEGORY, $count          );
    
    $details->{'text'        } = $raw_block;
    $details->{'no_paragraph'} = 1;
}


sub reset_count {
    my $self = shift;
    
    $self->set_metadata( $CATEGORY, 'current_block', 1 );
}


1;