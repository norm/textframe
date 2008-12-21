package Text::Frame;

use strict;
use warnings;

use Class::Trigger;
use IO::All -utf8;
use Readonly;
    Readonly my $CLASS_PREFIX => 'Text::Frame::';
    
use Module::Pluggable   require => 1,
                        search_path => "Text::Frame";

use Data::Dumper;



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
        print "** $plugin\n";
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



sub get_string {
    my $self = shift;
    
    return $self->{'string'};
}
sub set_string {
    my $self   = shift;
    my $string = shift;
    
    $self->{'string'} = $string;
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
        
        print "BLOCK\n$block\n";
        
        my $type  = $self->get_trigger_return( 
                        'detect_block', 
                        $block, 
                        \@blocks 
                    );
        
        print "TYPE $type\n";
        
        substr $string, 0, length $match, '';
    }
    print "REMAINING\n$string";
    exit;
}



sub sorted_plugins {
    my $self = shift;
    
    my %sorted_plugins;
    my @plugins = $self->plugins();
    
    foreach my $plugin ( @plugins ) {
        my @before;
        my @after;
        
        {
            no strict 'refs';
            @before = @{"${plugin}::plugin_before"};
            @after  = @{"${plugin}::plugin_after"};
        }
        
        $plugin =~ s{ $CLASS_PREFIX }{}x;
        foreach my $before ( @before ) {
            $sorted_plugins{$plugin}{$before} = 1;
        }
        foreach my $after ( @after ) {
            $sorted_plugins{$after}{$plugin}  = 1;
        }
    }
    
    return sort {
            my $a_before_b =  defined $sorted_plugins{$a}{$b} 
                           || defined $sorted_plugins{'*'}{$b};
            my $b_before_a =  defined $sorted_plugins{$b}{$a} 
                           || defined $sorted_plugins{'*'}{$a};
            
            return -1 if $a_before_b;
            return  1 if $b_before_a;
            return  0;
        } @plugins;
}
sub get_trigger_return {
    my $self    = shift;
    my $trigger = shift;
    my @args    = @_;
    
    $self->call_trigger( $trigger, @args );
    
    my $returns = $self->last_trigger_results();
    foreach my $return ( @{ $returns } ) {
        my $value = shift @{ $return };
        if ( defined $value ) {
            return $value;
        }
    }
    return;
}

1;
