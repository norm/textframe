package Text::Frame;

use strict;
use warnings;

use Class::Trigger;
use IO::All -utf8;
use Readonly;
    Readonly my $CLASS_PREFIX => 'Text::Frame::';
    
use Module::Pluggable   require => 1,
                        search_path => "Text::Frame";



sub new {
    my $proto = shift;
    my %args  = @_;
    
    my $class = ref $proto || $proto;
    my $self = {
        'string' => '',
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
        $self->{$arg} = $args{$arg};
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
    
    return $self;
}


sub decode_string {
    my $self   = shift;
    my $string = shift;
    
    my @blocks;
    my $decode_block = qr{
        ^
        (                   # the whole block (for later replacement)
            (?:
                \s* \n      # skip optional leading whitespace
            )*
            (
                .*?         # capture anything
            )
            \s* \n          # up to a newline...
            (?:
                \s* \n      # ...followed by at least one blank line
            )+
        )
    }xs;
    
    $string .= "\n\n";      # ensure we can match the final block
    
    while ( $string =~ $decode_block ) {
        my $match = $1;
        my $block = $2;
        
        my @context;
        my $block_type = '';
        my $previous   = '';
        my $new_block;
        
        while ( 'block' ne $block_type ) {
            ( $block_type, $new_block ) 
                = $self->get_first_trigger_return( 
                      'detect_text_block', 
                      $block, 
                      $previous
                  );
                  
            $block    = $new_block;
            $previous = $block_type;
            push @context, $block_type;
        }
        
        push @blocks, {
                'context' => \@context,
                'text'    => $block,
            };
        substr $string, 0, length $match, '';
    }
    
    $self->set_blocks( @blocks );
}


sub as_html {
    my $self   = shift;
    my @blocks = $self->get_blocks();
    my $output;
    
    my $block = shift @blocks;
    while ( $block ) {
        my $next_block = shift @blocks;
        my $text     = $block->{'text'};
        my @contexts = @{ $block->{'context'} };
        my %details  = ( 
                text       => $text,
                start_tags => [],
                end_tags   => [],
            );
        
        # allow each context to influence the output
        my $count = 0;
        foreach my $context ( @contexts ) {
            $self->call_trigger(
                    "output_as_html_${context}",
                    \%details,
                    $count,
                    $block,
                    $next_block,
                );
            $count++;
        }
        
        my $body       = $details{'text'};
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
sub as_text {
    my $self   = shift;
    my @blocks = $self->get_blocks();
    my $output;
    
    foreach my $block ( @blocks ) {
        my $text     = $block->{'text'};
        my @contexts = @{ $block->{'context'} };
        my %details  = (
                prefix     => '',
                first_line => '',
                right      => 78,
                text       => $text,
            );
        
        # allow each context to influence the output
        foreach my $context ( @contexts ) {
            $self->call_trigger(
                    "output_as_text_${context}",
                    \%details,
                );
        }
        
        # allow extra formatting for the block        
        $self->call_trigger( 
                'format_output_text',
                \%details,
            );
        
        my $block  = $details{'text'};
        my $prefix = $details{'prefix'};
        
        $block = $details{'first_line'} . $block;
        $block =~ s{\n}{\n$prefix}gs;
        
        $output .= "$block\n\n";
    }
    
    return $output;
}


sub sorted_plugins {
    my $self = shift;
    
    my %sorted_plugins;
    my @plugins;
    
    foreach my $plugin ( $self->plugins() ) {
        $plugin =~ s{ $CLASS_PREFIX }{}x;
        push @plugins, $plugin;
    }
    
    PLUGIN:
    foreach my $plugin ( @plugins ) {
        my @before;
        my @after;
        
        {
            no strict 'refs';
            @before = @{"${CLASS_PREFIX}${plugin}::plugin_before"};
            @after  = @{"${CLASS_PREFIX}${plugin}::plugin_after"};
        }
        
        BEFORE:
        foreach my $before ( @before ) {
            if ( '*' eq $before ) {
                BEFORE_PLUGIN:
                foreach my $before_plugin ( @plugins ) {
                    next BEFORE_PLUGIN if ( $before_plugin eq $plugin );
                    $sorted_plugins{$plugin}{$before_plugin} = 1;
                }
            }
            else {
                $sorted_plugins{$plugin}{$before} = 1;
            }
        }
        AFTER:
        foreach my $after ( @after ) {
            if ( '*' eq $after ) {
                AFTER_PLUGIN:
                foreach my $after_plugin ( @plugins ) {
                    next AFTER_PLUGIN if ( $after_plugin eq $plugin );
                    $sorted_plugins{$after_plugin}{$plugin} = 1;
                }
            }
            else {
                $sorted_plugins{$after}{$plugin}  = 1;
            }
        }
    }
    
    return sort {
            my $a_before_b =  defined $sorted_plugins{$a}{$b};
            my $b_before_a =  defined $sorted_plugins{$b}{$a};
            
            return -1 if $a_before_b;
            return  1 if $b_before_a;
            return  0;
        } @plugins;
}


sub get_trigger_single_returns {
    my $self    = shift;
    my $trigger = shift;
    my @args    = @_;
    
    $self->call_trigger( $trigger, @args );
    
    my @return;
    my $returns = $self->last_trigger_results();
    foreach my $return ( @{ $returns } ) {
        my $value = shift @{ $return };
        if ( defined $value ) {
            push @return, $value;
        }
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
        if ( $#{ $return } > -1 ) {
            return @{ $return };
        }
    }
    return;
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
sub get_blocks {
    my $self = shift;
    
    return @{ $self->{'blocks'} };
}
sub set_blocks {
    my $self   = shift;
    my @blocks = @_;
    
    $self->{'blocks'} = \@blocks;
}


1;
