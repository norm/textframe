package Text::Frame;

use strict;
use warnings;

use utf8;
use version;            our $VERSION = qv( '0.5.5' );

use Class::Trigger;
use HTML::Parser;
use IO::All -utf8;
use Module::Pluggable   require     => 1,
                        search_path => "Text::Frame";
use Readonly;
use Storable            qw( dclone );

Readonly my $CLASS_PREFIX => 'Text::Frame::';
    


sub new {
    my $proto = shift;
    my %args  = @_;
    
    my $class = ref $proto || $proto;
    my $self  = {
            string   => '',
            links    => {},
            metadata => {},
            insert   => [],
        };
    bless $self, $class;
    
    # read in file argument to replace current string
    my $file = $args{'file'};
    if ( defined $file ) {
        my $io = io $file;
        $self->set_string( $io->all );
        delete $args{'file'};
    }
    
    foreach my $arg ( keys %args ) {
        $self->{ $arg } = $args{ $arg };
    }
    
    foreach my $plugin ( $self->sorted_plugins() ) {
        $plugin = "${CLASS_PREFIX}${plugin}";
        if ( $plugin->can( 'initialise' ) ) {
            $plugin->initialise( $self );
        }
    }
    
    # decode the string into the individual blocks
    my $string = $self->get_string();
    if ( defined $string ) {
        $self->decode_string( $string );
    }
    
    if ( defined $args{'blocks'} ) {
        $self->set_blocks( @{ $args{'blocks'} } );
    }
    
    return $self;
}


sub decode_string {
    my $self   = shift;
    my $string = shift;
    
    if ( $string =~ m{^ \s* [<] [\w!]+ }sx ) {
        $self->set_input_type( 'html' );
        $self->decode_html_string( $string );
    }
    else {
        $self->set_input_type( 'text' );
        $self->decode_text_string( $string );
    }
}


sub decode_html_string {
    my $self   = shift;
    my $string = shift;
    
    my %details = (
            blocks => [],
        );
    
    $details{'block_insert'} = $details{'blocks'};
    
    my $html = HTML::Parser->new( 
            api_version => 3,
            handlers => {
                start => [
                    sub { 
                        my $html = shift;
                        my $tag  = shift;
                        
                        $self->call_trigger(
                                "decode_html_start_${tag}",
                                \%details,
                                $html,
                                $tag,
                                @_
                            );
                    },
                    'self, tagname, attr',
                ],
                end => [
                    sub { 
                        my $html = shift;
                        my $tag  = shift;
                
                        $self->call_trigger(
                                "decode_html_end_${tag}",
                                \%details,
                                $html,
                                $tag,
                                @_
                            );
                    },
                    'self, tagname, attr',
                ],
                text => [
                    sub { 
                        my $html = shift;
                    
                        $self->call_trigger(
                                "decode_html_string",
                                \%details,
                                $html,
                                @_
                            );
                    },
                    'self, text',
                ],
                comment => [
                    sub { 
                        my $html = shift;
                        
                        $self->call_trigger(
                                "decode_html_comment",
                                \%details,
                                $html,
                                @_
                            );
                    },
                    'self, text',
                ],
            },
        );
    
    $html->parse( $string );
    $self->set_blocks( @{ $details{'blocks'} } );
}
sub add_new_html_block {
    my $self    = shift;
    my $details = shift;
    
    if ( defined $details->{'current_block'} ) {
        my $insert = $self->get_block_insert_point();
        
        if ( defined $insert ) {
            push @{ $insert }, $details->{'current_block'};
        }
        else {
            push @{ $details->{'blocks'} }, $details->{'current_block'};
        }
        
        delete $details->{'current_block'};
        $self->{'insert'} = [];
    }
}
sub add_block_insert_point {
    my $self  = shift;
    my $point = shift;
    
    push @{ $self->{'block_insert'} }, $point;
}
sub get_block_insert_point {
    my $self = shift;
    
    my $inserts = $self->{'block_insert'};
    
    return $inserts->[$#$inserts];
}
sub remove_block_insert_point {
    my $self = shift;
    
    pop @{ $self->{'block_insert'} };
}
sub add_insert_point {
    my $self  = shift;
    my $point = shift;
    
    push @{ $self->{'insert'} }, $point;
}
sub remove_insert_point {
    my $self = shift;
    
    pop @{ $self->{'insert'} };
}
sub get_insert_point {
    my $self    = shift;

    my $inserts = $self->{'insert'};
    
    return $inserts->[$#$inserts];
}


sub decode_text_string {
    my $self   = shift;
    my $string = shift;
    
    # normalise carriage returns and carriage return+newlines to newlines
    $string =~ s{ \r\n }{\n}gsx;
    $string =~ s{ \r   }{\n}gsx;

    # remove any leading blank lines, and then add a double newline
    # to ensure the block split regexp works properly
    $string =~ s{ ^ (?: \s* \n )* }{}x;
    $string .= "\n\n";
    
    my $decode_block = qr{
            ^
            (                   # the whole block (for later replacement)
                (
                    .*?         # capture anything
                    \n          # finishing with a newline...
                )
                (               # and capture the blank lines following
                    \s* \n      # as they are significant
                )+
            )
        }sx;
    
    my $gap_hint = '';
    my @blocks;
    while ( $string =~ $decode_block ) {
        my $all_matched = $1;
        my $block       = $2;
        my $this_hint   = $3;
        
        my $block_type = '';
        my $previous   = '';
        my $has_indent = 0;
        my $new_block;
        my @context;
        my %metadata;
        
        # strip away any outer "layers" of type hinting on the block, 
        # until you are left with just the actual text of the block
        while ( 'block' ne $block_type ) {
            ( $block_type, $new_block ) 
                = $self->get_first_trigger_return( 
                      'detect_text_block', 
                      $block, 
                      $previous,
                      $gap_hint,
                      \%metadata, 
                      \@context,
                  );
            
            $has_indent = 1  if 'indent' eq $block_type;
            $block      = $new_block;
            $previous   = $block_type;
            
            push @context, $block_type;
        }
        
        # reduce all white space as it is not significant
        $block =~ s{  \s+            }{ }gsx;
        $block =~ s{^ \s* (.*?) \s* $}{$1}gsx;

        # parse the text for the inline elements
        my @elements = $self->decode_inline_text( $block );
        
        # determine if the block contains only links: two clues are that 
        # reference links have no indentation...
        my $links_only = ( !$has_indent );
        
        # ... and that the entire block should contain 
        # only empty strings and links 
        TEST:
        foreach my $element ( @elements ) {
            my $type = $element->{'type'};
            my $text = $element->{'text'};
            
            next TEST  if 'link' eq $type;
            next TEST  if ( 'string' eq $type  
                            && ( q() eq $text  ||  q( ) eq $text )
                          );
            
            $links_only = 0;
        }
        
        # reference links should not be treated as 
        # an output block when parsing documents)        
        if ( !$links_only ) {
            push @blocks, {
                    'context'  => \@context,
                    'metadata' => \%metadata,
                    'elements' => \@elements,
                };
        }
        
        $gap_hint = $this_hint;
        substr $string, 0, length $all_matched, '';
    }
    
    $self->set_blocks( @blocks );
}
sub decode_inline_text {
    my $self = shift;
    my $text = shift;
    
    my( $start, $data, $end ) = $self->get_first_element_match( $text );
    my @elements;
    
    if ( defined $start ) {
        push @elements,  $self->decode_inline_text( $start );
        
        if ( defined $data->{'string'} ) {
            @{ $data->{'contents'} }
                = $self->decode_inline_text( $data->{'string'} );
            delete $data->{'string'};
        }
        push @elements,  $data;
        
        push @elements,  $self->decode_inline_text( $end );
    }
    elsif ( defined $data ) {
        push @elements,  $data;
    }
    
    return @elements;
}
sub get_first_element_match {
    my $self = shift;
    my $text = shift;
    
    my @stuff = $self->get_all_trigger_returns(
                    'detect_text_string',
                    $text
                );
    
    # if there's only one return value, use it
    return @{ shift @stuff }  if 0 == $#stuff;
    
    my $shortest_length = length $text;
    my $return_value;
    
    RETURN:
    foreach my $return ( @stuff ) {
        my $details       = $return->[1];
        my $before_length = defined $return->[0]
                                ? length $return->[0] 
                                : 0;
        
        # ignore the string type, because that will be the
        # entire string, including any sub-elements
        next RETURN  if 'string' eq $details->{'type'};
        
        if ( $shortest_length > $before_length ) {
            $shortest_length = $before_length;
            $return_value    = $return;
        }
    }
    
    return @{ $return_value };
}
sub store_link {
    my $self = shift;
    my $text = shift;
    my $uri  = shift;
    
    my $links = $self->{'links'};
    my $link  = $links->{ $text };
    
    if ( defined $link ) {
        my $check_uri = $self->get_link( $text );
        return 1  if ( $check_uri eq $uri );
    }
    else {
        $links->{ $text } = $uri;
        return 1;
    }
    return;
}
sub get_link {
    my $self = shift;
    my $text = shift;
    
    return $self->{'links'}{ $text };
}
sub get_links {
    my $self = shift;
    
    return $self->{'links'};
}


sub as_html {
    my $self   = shift;
    
    my @blocks = $self->get_blocks();
    my $output;
    
    # allow metadata setup for a new document
    $self->call_trigger( 
            'start_html_document', 
            \$output, 
            \@blocks 
        );
    
    my $block = shift @blocks;
    while ( $block ) {
        my $next_block = shift @blocks;
        my @contexts   = @{ $block->{'context'} };
        my $text       = $self->block_as_html( 
                             undef, 
                             @{ $block->{'elements'} }
                         );
        my %details    = ( 
                             text       => $text,
                             start_tags => [],
                             end_tags   => [],
                             metadata   => $block->{'metadata'},
                         );
            
        # allow each context to influence the output
        my $count = 0;
        foreach my $context ( @contexts ) {
            $self->call_trigger(
                    "block_as_html_${context}",
                    \%details,
                    $count,
                    $block,
                    $next_block,
                );
            $count++;
        }
        
        # allow extra formatting for the block        
        $self->call_trigger( 
                'format_block_html',
                \%details,
            );
        
        my $body       = $details{'text'} || q();
        my $start_tags = join q(), @{ $details{'start_tags'} };
        my $end_tags   = join q(), reverse @{ $details{'end_tags'} };
        my $string     = join q(), $start_tags,
                                   $body,
                                   $end_tags,
                                   "\n";
        $output .= $string;
        $block   = $next_block;
    }

    return $output;
}
sub block_as_html {
    my $self          = shift;
    my $outer_context = shift;
    my @elements      = @_;
    
    my $block;
    foreach my $element ( @elements ) {
        my $type     = $element->{'type'};
        my $contents = $element->{'contents'};
        my $context;
        
        if ( defined $outer_context ) {
            $context = dclone( $outer_context );
        }
        
        if ( defined $contents ) {
            $context->{'type'} = $type;
            $context->{'nested'}++;
            push @{ $context->{'types'} },  $element->{'type'};
            
            $element->{'text'} = $self->block_as_html( 
                                  $context, 
                                  @{ $contents },
                              );
        }
        
        $self->call_trigger(
                "as_html_${type}",
                $element,
                \$block,
                $context,
            );
    }
    
    return $block;
}


sub as_text {
    my $self     = shift;
    my %metadata = @_;
    
    my @blocks = $self->get_blocks();
    my $output;
    
    # allow metadata setup for a new document
    $self->call_trigger( 
            'start_text_document', 
            \$output, 
            \@blocks 
        );
    
    my $block = shift @blocks;
    while ( $block ) {
        my $next_block = shift @blocks;
        my @contexts   = @{ $block->{'context'} };
        my $text       = $self->block_as_text( 
                             undef, 
                             @{ $block->{'elements'} },
                         );
        my %details    = (
                             prefix     => q(),
                             first_line => q(),
                             right      => 78,
                             text       => $text,
                             metadata   => $block->{'metadata'},
                         );
        
        # copy arguments over
        foreach my $key ( keys %metadata ) {
            $details{ $key } = $metadata{ $key };
        }
        
        # preserve original values
        KEY:
        foreach my $key ( keys %details ) {
            next KEY  if 'metadata' eq $key;
            
            $details{"original_${key}"} = $details{ $key };
        }
        
        # allow each context to influence the output
        my $count = 0;
        foreach my $context ( @contexts ) {
            $self->call_trigger(
                    "block_as_text_${context}",
                    \%details,
                    $count,
                    $block,
                    $next_block,
                );
            $count++;
        }
        
        # allow extra formatting for the block        
        $self->call_trigger( 
                'format_block_text',
                \%details,
            );
        
        my $body       = $details{'text'};
        my $prefix     = $details{'prefix'};
        my $first_line = $details{'first_line'};
        
        $body  = "${first_line}${body}";
        $body =~ s{\n}{\n$prefix}gs;
        
        $output .= "$body\n\n";
        $block   = $next_block;
    }
    
    # allow extra formatting for the entire document        
    $self->call_trigger( 
            'format_document_text', 
            \$output 
        );
    
    return $output;
}
sub block_as_text {
    my $self          = shift;
    my $outer_context = shift;
    my @elements      = @_;
    my $block;
    
    foreach my $element ( @elements ) {
        my $type     = $element->{'type'};
        my $contents = $element->{'contents'};
        my $context;
        
        if ( defined $outer_context ) {
            $context = dclone( $outer_context );
        }
        
        if ( defined $contents ) {
            $context->{'type'} = $type;
            $context->{'nested'}++;
            push @{ $context->{'types'} }, $element->{'type'};
            
            $element->{'text'} = $self->block_as_text( $context, 
                                                    @{ $contents } );
        }

        $self->call_trigger(
                "as_text_${type}",
                $element,
                \$block,
                $context,
            );
    }
    
    return $block;
}


sub sorted_plugins {
    my $self = shift;
    
    my %sorted_plugins;
    my @plugins;
    
    foreach my $plugin ( $self->plugins() ) {
        $plugin =~ s{ $CLASS_PREFIX }{}x;
        push @plugins,  $plugin;
    }
    
    PLUGIN:
    foreach my $plugin ( @plugins ) {
        my @before;
        my @after;
        
        $sorted_plugins{ $plugin } = [];

        {
            ## no critic
            no strict 'refs';
            @before = @{"${CLASS_PREFIX}${plugin}::plugin_before"};
            @after  = @{"${CLASS_PREFIX}${plugin}::plugin_after"};
        }
        
        foreach my $before ( @before ) {
            push @{ $sorted_plugins{ $plugin } }, $before;
        }
        
        foreach my $after ( @after ) {
            push @{ $sorted_plugins{ $after } }, $plugin;
        }
    }
    
    return $self->sorted_dependencies( \%sorted_plugins );
}
sub sorted_dependencies {
    my $self   = shift;
    my $values = shift;
    my %depths;
    
    foreach my $item ( keys %$values ) {
        $depths{ $item } = $self->dependency_depth( $item, $values );
    }
    
    return sort {
            return $depths{ $b } <=> $depths{ $a };
        } keys %depths;
}
sub dependency_depth {
    my $self   = shift;
    my $item   = shift;
    my $values = shift;
    my $seen   = shift || {};
    
    return 0  if defined $seen->{$item};
    
    $seen->{$item} = 1;
    my $depth = 0;
    foreach my $child ( @{ $values->{ $item } } ) {
        my $children = $self->dependency_depth( $child, $values, $seen );
        $depth = $children if $children > $depth;
    }
    return $depth + 1;
}


sub get_trigger_single_returns {
    my $self    = shift;
    my $trigger = shift;
    my @args    = @_;
    
    $self->call_trigger( $trigger, @args );
    my $returns = $self->last_trigger_results();
    my @return;
    
    foreach my $return ( @{ $returns } ) {
        my $value = shift @{ $return };
        
        push( @return,  $value )  if defined $value;
    }
    
    return @return;
}
sub get_first_trigger_return {
    my $self    = shift;
    my $trigger = shift;
    my @args    = @_;
    
    $self->call_trigger( $trigger, @args );
    my $returns = $self->last_trigger_results();
    
    foreach my $return ( @{ $returns } ) {
        return @{ $return }  if $#{ $return } > -1;
    }
    
    return;
}
sub get_all_trigger_returns {
    my $self    = shift;
    my $trigger = shift;
    my @args    = @_;
    
    $self->call_trigger( $trigger, @args );
    my $returns = $self->last_trigger_results();
    my @returns;
    
    foreach my $return ( @{ $returns } ) {
        push( @returns, $return )  if $#{ $return } > -1;
    }
    
    return @returns;
}


sub get_string {
    my $self = shift;
    
    return $self->{'string'};
}
sub set_string {
    my $self   = shift;
    my $string = shift;
    
    $self->{'string'} = $string;
}
sub get_metadata {
    my $self     = shift;
    my $category = shift;
    my $item     = shift;
    
    return() if ( !defined $item );
    return $self->{'metadata'}{ $category }{ $item };
}
sub get_metadata_category {
    my $self     = shift;
    my $category = shift;

    return $self->{'metadata'}{ $category };
}
sub set_metadata {
    my $self     = shift;
    my $category = shift;
    my $item     = shift;
    my $value    = shift;
    
    my $metadata = $self->{'metadata'};
    
    if ( !defined $metadata->{ $category } ) {
        $metadata->{ $category } = {};
    }
    
    $metadata->{ $category }{ $item } = $value;
}
sub reset_metadata_category {
    my $self = shift;
    my $category = shift;
    
    $self->{'metadata'}{ $category } = {};
}
sub get_blocks {
    my $self = shift;
    
    return @{ $self->{'blocks'} };
}
sub set_blocks {
    my $self   = shift;
    my @blocks = @_;
    
    $self->{'blocks'} = \@blocks;
}
sub reset_blocks {
    my $self = shift;
    delete $self->{'blocks'};
}
sub set_input_type {
    my $self = shift;
    my $type = shift;
    
    $self->{'input_type'} = $type;
}
sub get_input_type {
    my $self = shift;
    
    return $self->{'input_type'};
}

1;
