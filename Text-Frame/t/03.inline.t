use strict;
use warnings;

use Test::More      tests => 1;

use Text::Frame;


my $phrase = 'A sentence.';
my @data   = ( 
        {
            type => 'string',
            text => 'A sentence.',
        },
    );

my $frame      = Text::Frame->new();
my @check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );
