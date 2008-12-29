use strict;
use warnings;

use Test::More      tests => 1;

use Text::Frame;


my $block = <<END;

        A simple paragraph block.

END
my @data  = ( 
        {
            text => [
                {
                    text => 'A simple paragraph block.',
                    type => 'string',
                },
            ],
            context => [
                'indent',
                'indent',
                'block',
            ],
        } 
    );

my $frame      = Text::Frame->new( string => $block );
my @check_data = $frame->get_blocks();

is_deeply( \@data, \@check_data );
