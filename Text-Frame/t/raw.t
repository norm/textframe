use strict;
use warnings;

use utf8;

use Test::More      tests => 6;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A sentence with |raw| text.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'raw',
        },
        {
            type => 'string',
            text => ' text.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with |two| little |bits of| raw text.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'two',
        },
        {
            type => 'string',
            text => ' little ',
        },
        {
            type => 'raw',
            text => 'bits of',
        },
        {
            type => 'string',
            text => ' raw text.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with |raw text|.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'raw text',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with |raw *not* emphasised text|.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'raw *not* emphasised text',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with |raw <em>not linked</em> text|.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'raw <em>not linked</em> text',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with |raw «not code» text|.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'raw',
            text => 'raw «not code» text',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



