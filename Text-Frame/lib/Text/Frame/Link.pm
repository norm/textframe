package Text::Frame::Link;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_string   => \&detect_text_string );
    $frame->add_trigger( decode_html_start_a => \&start_html_link     );
    $frame->add_trigger( decode_html_end_a   => \&end_html_link       );
    
    $frame->add_trigger( as_text_link         => \&as_text            );
    $frame->add_trigger( format_document_text => \&reference_links    );
    
    $frame->add_trigger( as_html_link         => \&as_html            );
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    my $links_regexp = qr{
            ^
            
            ( .*? )                     # capture everything before the link
            
            [<]
            (?:                         # optional link text (which cannot
                ( [^\s>|] [^>|]+? )     #   start with a space or contain 
                \s*                     #   | or > chars)
                [|]                     # link text terminated
                \s*
            )?
            (                           # capture the URI (also cannot start
                [^\s\W>|][^|>]+?        #   with a space or contain 
            )                           #   | or > chars)
            \s*
            [>]
            
            ( .*? )                 # capture everything after the link
            
            $
        }sx;
    
    if ( $string =~ $links_regexp ) {
        my $before = $1;
        my $text   = $2;
        my $uri    = $3;
        my $after  = $4;
        
        my $uri_has_protocol = ( $uri =~ m{^ \w+ [:][/][/] }x );
        my $uri_is_relative  = ( $uri =~ m{^ [.]? [/]      }x );
        my $is_uri           = $uri_has_protocol || $uri_is_relative;
        
        # if the URI is not actually a URI, assume it is link text
        # that is shared with another link which does specify the URI
        if ( !$is_uri ) {
            $text = $uri;
            $uri  = '';
        }
        
        # white space within URIs is allowed in textframe source, but ignored
        $uri =~ s{\s}{}gs;
        
        if ( $uri ) {
            if ( $self->store_link( $text, $uri ) ) {
                $uri = q();
            }
        }

        my %hash = (
                type => 'link',
                text => $text
            );
        
        $hash{'uri'} = $uri  if q() ne $uri;
        
        return(
                $before,
                \%hash,
                $after,
            );
    }
    
    return;
}


sub start_html_link {
    my $self    = shift;
    my $details = shift;
    my $html    = shift;
    my $tag     = shift;
    my @attr    = @_;
    
    my $uri;
    foreach my $attribute ( @attr ) {
        foreach my $key ( keys %{ $attribute } ) {
            if ( 'href' eq $key ) {
                $uri = $attribute->{ $key };
            }
        }
    }
    
    if ( defined $uri ) {
        my $insert  = $self->get_insert_point();
        my %element = (
                type => 'link',
                contents => [],
                uri => $uri,
            );

        push @{ $insert }, \%element;
        $self->add_insert_point( $element{'contents'} );
    }
}
sub end_html_link {
    my $self = shift;
    
    $self->remove_insert_point();
    
    my $insert   = $self->get_insert_point();
    my $block    = $insert->[$#$insert];
    my $contents = $block->{'contents'};
    
    $block->{'text'} = $self->block_as_text( undef, @{ $contents } );
    
    if ( $self->store_link( $block->{'text'}, $block->{'uri'} ) ) {
        delete $block->{'uri'};
    }
    
    delete $block->{'contents'};
}


sub as_text {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    my $uri  = $item->{'uri'};
    
    if ( !$uri ) {
        $uri = $self->get_link( $text );
    }
    
    # extract the URI for reference links, unless it already has been and
    # the URIs do not match (this would destroy a link)
    my $ref_uri = $self->get_metadata( 'reference_links', $text );
    if ( defined $ref_uri ) {
        $uri = q()  if $ref_uri eq $uri;
    }
    else {
        $self->set_metadata( 'reference_links', $text, $uri );
        $uri = q();
    }

    if ( $uri ) {
        $$block .= "<$text | $uri>";        
    }
    else {
        $$block .= "<$text>";
    }
}
sub reference_links {
    my $self   = shift;
    my $output = shift;
    
    my $links = $self->get_metadata_category( 'reference_links' );
    
    if ( defined $links ) {
        foreach my $text ( keys %{ $links } ) {
            my $uri = $links->{ $text } || q();

            my $link_text = "<$text | $uri>\n";
            if ( length $link_text > 78 ) {
                # TODO - better formatting please
                $link_text = "<$text |\n$uri\n>\n";
            }
            $$output .= $link_text;
        }
    }
}


sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    my $uri  = $item->{'uri'};

    if ( !$uri ) {
        $uri = $self->get_link( $text ) || '#BROKEN';
    }
    
    $self->call_trigger( 'html_string_escape', \$text );
    
    $$block .= "<a href='${uri}'>${text}</a>";
}




1;
