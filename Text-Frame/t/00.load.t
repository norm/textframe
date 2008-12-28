use strict;
use warnings;

use Test::More tests => 2;

# ensure the module can be loaded

use_ok( 'Text::Frame' );

my $frame = Text::Frame->new();

isa_ok( $frame, 'Text::Frame' );
