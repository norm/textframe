package Text::Frame::Blockquote;

use strict;
use warnings;

use utf8;

use Readonly;

Readonly my $CATEGORY => 'blockquote';



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block        => \&detect_text_block );
    
    $frame->add_trigger( start_text_document      => \&reset_count       );
    $frame->add_trigger( block_as_text_blockquote => \&as_text           );
    
    $frame->add_trigger( start_html_document      => \&reset_count       );
    $frame->add_trigger( block_as_html_blockquote => \&as_html           );
    
    reset_count( $frame );
}


sub detect_text_block {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    
    my $find_quote_regexp = qr{
            ^
            (?:
                [>]             # quote is a greater-than symbol
                [ ]{3}          #   three spaces (to make it a full indent)
                
                |               # or
                
                From            # citation line
                \s+
                [<] 
                ( [^>]+ )       # capture the link
                [>][:]
                \s*
            )
        }sx;
    my $strip_quote_regexp = qr{
            ^
            [>]                 # quote is a greater-than symbol
        
            (?:                 # followed by either:
                [ ]{3}          #   three spaces (to make it a full indent)
                
                |               #   or
                
                \s* $           #   an empty line
            )
        }mx;
    
    if ( $block =~ s{$find_quote_regexp}{}x ) {
        my $citation = $1;
        
        # if the line starts with a from: citation,
        # it must still be quoted
        return unless $block =~ s{$strip_quote_regexp}{    }g;

        my $current = $self->get_metadata( $CATEGORY, 'current' ) + 1;
        my $frame = Text::Frame->new( string => $block );
        
        $self->set_metadata( $CATEGORY, "quote_${current}", $frame    );
        $self->set_metadata( $CATEGORY, 'current',          $current  );
        $self->set_metadata( 
                $CATEGORY, 
                "cite_${current}",  
                $citation 
            ) if $citation;
        
        return( 
                  'blockquote',
                  q(),
            );
    }
    
    return;
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    my $current   = $self->get_metadata( $CATEGORY, 'current'        ) + 1;
    my $frame     = $self->get_metadata( $CATEGORY, "quote_$current" );
    my $citation  = $self->get_metadata( $CATEGORY, "cite_$current"  );
    my $depth     = $details->{'blockquote_depth'} || 0;
    my $text      = $frame->as_text( blockquote_depth => $depth + 1 );

    # remove the first indent from the generated document
    $text =~ s{^ [ ]{4} }{}gmx;

    $details->{'formatted'}  = 1;
    $details->{'prefix'   } .= '>   ';
    $details->{'right'    } -= 4;

    if ( defined $citation ) {
        my $cite_link = $self->get_link( $citation );
        
        $text = "From <$citation>:\n${text}";
        $self->set_metadata( 'reference_links', $citation, $cite_link );
    }
    else {
        $details->{'first_line'} .= '>   ';
    }
    
    $details->{'text'}  = $text;
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    
    # set contents of the block to the sub-document
    my $current  = $self->get_metadata( $CATEGORY, 'current'        ) + 1;
    my $frame    = $self->get_metadata( $CATEGORY, "quote_$current" );
    my $citation = $self->get_metadata( $CATEGORY, "cite_$current"  );
    
    if ( defined $frame ) {
        $details->{'text'} = $frame->as_html();
        
        my $cite_attribute = q();
        if ( defined $citation ) {
            $cite_attribute = " cite='"
                            . $self->get_link( $citation )
                            . q(');
        }
        
        $details->{'no_paragraph'} = 1;
        push @{ $details->{'start_tags'} }, "<blockquote${cite_attribute}>";
        push @{ $details->{'end_tags'}   }, '</blockquote>';
    }
}


sub reset_count {
    my $self = shift;
    
    $self->set_metadata( $CATEGORY, 'current', 0 );
}


1;
