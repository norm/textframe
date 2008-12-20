package Text::Frame;

use strict;
use warnings;

use Class::Trigger;
use Module::Pluggable   require => 1,
                        search_path => 'Text::Frame';

use IO::All -utf8;
use Readonly;


use Data::Dumper;


# TODO
#   *   order the plugins


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
        undef $args{'file'};
    }
    
    foreach my $arg ( keys %args ) {
        print "-> $arg\n";
        $self->{$arg} = $args{$arg};
    }
    
    foreach my $plugin ( $self->plugins() ) {
        if ( $plugin->can( 'initialise' ) ) {
            print "** $plugin\n";
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
                \s* \n      # skip leading whitespace
            )*
            (
                .*?         # capture anything
            )
            \n              # up to a newline...
            (?:
                \s* \n      # ...followed by at least one blank line
            )+
        )
    }x;
    
    $string .= "\n\n";      # ensure we can match the final block
    while ( $string =~ $decode_block ) {
        my $match = $1;
        my $block = $2;
        
        my $type  = $self->get_trigger_return( 'detect_block', $block );
        # $self->call_trigger( 'detect_block', $block, \$type );
        
        print "TYPE $type\n";
        # print Dumper $self->last_trigger_results();
        
        # foreach my $type ( @BLOCK_TYPES ) {
        #     no strict 'refs';
        #     
        #     my $sub = "Text::Frame::${type}::new";
        #     my $block = &{ $sub }( 'block' => $block );
        #     print Dumper $block;
        # }
        
        print "-- BLOCK:\n$block\n";
        
        substr $string, 0, length $match, '';
    }
    
    # print "** STRING **\n$string\n-- STRING --\n";
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



# sub from_file {
#     my $self = shift;
#     my $file = shift;
#     
#     # TODO add error checking
#     my $io = io $file;
#     $self->set_string( $io->all );
# }
# 
# 
# 
# sub as_html {
#     my $self = shift;
#     
#     
#     # foreach my $block ( $self->get_blocks() ) {
#     #     
#     # }
#     
#     my $string = $self->get_string();
#     print $string;
#     
#     # print Dumper $self;
#     # 
#     # # print "ARGH!\n";
#     # exit 1;
# }



1;
