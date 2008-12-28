use strict;
use warnings;

use Test::More      tests => 3;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A sentence with /some/ italics.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'italic',
            contents => [
                {
                    text => 'some',
                    type => 'string',
                },
            ],
        },
        {
            type => 'string',
            text => ' italics.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with /two/ little /bits of/ italics.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'italic',
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
            type     => 'italic',
            contents => [
                {
                    type => 'string',
                    text => 'bits of',
                },
            ],
        },
        {
            type => 'string',
            text => ' italics.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with /italics/.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type     => 'italic',
            contents => [
                {
                    type => 'string',
                    text => 'italics',
                },
            ],
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );
