use strict;
use warnings;

use Test::More      tests => 4;

use Text::Frame;


my $frame      = Text::Frame->new();
my $phrase     = 'A basic link to <Google | http://www.google.com/> here.';
my @check_data = $frame->decode_inline_text( $phrase );
my @data       = ( 
        {
            type => 'string',
            text => 'A basic link to ',
        },
        {
            type => 'link',
            text => 'Google',
            uri  => 'http://www.google.com/',
        },
        {
            type => 'string',
            text => ' here.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = 'Link to <Google | http://www.google.com/>.';
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'Link to ',
        },
        {
            type => 'link',
            text => 'Google',
            uri  => 'http://www.google.com/',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = "A link that <spans\nlines | http://www.google.com/>.";
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'A link that ',
        },
        {
            type => 'link',
            text => "spans\nlines",
            uri  => 'http://www.google.com/',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



$phrase     = <<END;
This link is <totally
    spread out |
        http://www.
        google.com/
>.
END
@check_data = $frame->decode_inline_text( $phrase );
@data       = ( 
        {
            type => 'string',
            text => 'This link is ',
        },
        {
            type => 'link',
            text => "totally\n    spread out",
            uri  => 'http://www.google.com/',
        },
        {
            type => 'string',
            text => '.',
        },
    );

is_deeply( \@data, \@check_data );



