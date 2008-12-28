use strict;
use warnings;

use utf8;

use Test::More      tests => 6;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A sentence with «some» code.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'code',
            text => 'some',
        },
        {
            type => 'string',
            text => ' code.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with <<some>> code.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with «two» little «bits of» code.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'code',
            text => 'two',
        },
        {
            type => 'string',
            text => ' little ',
        },
        {
            type => 'code',
            text => 'bits of',
        },
        {
            type => 'string',
            text => ' code.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with <<two>> little <<bits of>> code.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with «code».';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A sentence with ',
        },
        {
            type => 'code',
            text => 'code',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'A sentence with <<code>>.';
@check_data = $frame->decode_inline_text( $phrase );

is_deeply( \@data, \@check_data );

