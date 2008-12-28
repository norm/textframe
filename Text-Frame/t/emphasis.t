use strict;
use warnings;

use Test::More      tests => 14;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A sentence with _a little_ emphasis.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    text => 'a little',
                    type => 'string',
                },
            ],
        },
        {
            type => 'string',
            text => ' emphasis.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with *a little* emphasis.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with two *little* *bits* of emphasis.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with two ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'little',
                },
            ],
        },
        {
            type => 'string',
            text => ' ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'bits',
                },
            ],
        },
        {
            type => 'string',
            text => ' of emphasis.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with two _little_ _bits_ of emphasis.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with two *little* _bits_ of emphasis.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with two *little* _bits_ of emphasis.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'Simple sentence with *emphasis*.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'Simple sentence with ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'emphasis',
                },
            ],
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );




$phrase     = "A sentence with *emphasis split\n"
            . 'across* two lines.';
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => "emphasis split\nacross",
                },
            ],
        },
        {
            type => 'string',
            text => ' two lines.',
        },
    );
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = "A sentence with _emphasis split\n"
            . 'across_ two lines.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with *a _little_ nested* emphasis.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'a ',
                },
                {
                    type     => 'emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'little',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' nested',
                },
            ],
        },
        {
            type => 'string',
            text => ' emphasis.',
        },
    );

is_deeply( \@data, \@check_data );



# data structure should be identical, as the type
# of emphasis character used is irrelevant
$phrase     = 'A sentence with _a *little* nested_ emphasis.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence _with *three _levels_ of* emphasis_ cannot work.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'with *three _levels',
                },
            ],
        },
        {
            type => 'string',
            text => ' of* emphasis_ cannot work.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence *with _three *levels* of_ emphasis* cannot work.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'with _three *levels',
                },
            ],
        },
        {
            type => 'string',
            text => ' of_ emphasis* cannot work.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with _three_ *instances* of _emphasis_ can work.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'three',
                },
            ],
        },
        {
            type => 'string',
            text => ' ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'instances',
                },
            ],
        },
        {
            type => 'string',
            text => ' of ',
        },
        {
            type     => 'emphasis',
            contents => [
                {
                    type => 'string',
                    text => 'emphasis',
                },
            ],
        },
        {
            type => 'string',
            text => ' can work.',
        },
    );

is_deeply( \@data, \@check_data );
