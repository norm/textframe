use strict;
use warnings;

use Test::More      tests => 3;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A sentence with --some-- struck text.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'struck',
            contents => [
                {
                    text => 'some',
                    type => 'string',
                },
            ],
        },
        {
            type => 'string',
            text => ' struck text.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with --two-- little --bits of-- struck text.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'struck',
            contents => [
                {
                    type => 'string',
                    text => 'two',
                },
            ],
        },
        {
            type => 'string',
            text => ' little ',
        },
        {
            type     => 'struck',
            contents => [
                {
                    type => 'string',
                    text => 'bits of',
                },
            ],
        },
        {
            type => 'string',
            text => ' struck text.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with --struck text--.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'struck',
            contents => [
                {
                    type => 'string',
                    text => 'struck text',
                },
            ],
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );
