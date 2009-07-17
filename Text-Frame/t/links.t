use strict;
use warnings;

use Test::More      tests => 72;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my @ref_data;
my %links;
my $ref_doc;


# test links without titles are parsed correctly
$document = <<END;
        A basic link to <http://www.google.com/>.

END
$html = <<HTML;
<p>A basic link to <a href='http://www.google.com/'>http://www.google.com/</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'http://www.google.com/',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'http://www.google.com/' => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test links with titles are parsed correctly
$document = <<END;
        A basic link to <Google | http://www.google.com/>.

END
$ref_doc = <<END;
        A basic link to <Google>.

<Google | http://www.google.com/>
END
$html = <<HTML;
<p>A basic link to <a href='http://www.google.com/'>Google</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'Google' => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# check relative links work
$document = <<END;
        A basic link to <the homepage | />.

END
$ref_doc = <<END;
        A basic link to <the homepage>.

<the homepage | />
END
$html = <<HTML;
<p>A basic link to <a href='/'>the homepage</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'the homepage',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'the homepage' => '/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );

$document = <<END;
        A basic link to <another page | /some/other/page/>.

END
$ref_doc = <<END;
        A basic link to <another page>.

<another page | /some/other/page/>
END
$html = <<HTML;
<p>A basic link to <a href='/some/other/page/'>another page</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'another page',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'another page' => '/some/other/page/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# check relative links work
$document = <<END;
        A basic link to <another page>.

<another page | /another-page>
END
$html = <<HTML;
<p>A basic link to <a href='/another-page'>another page</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'another page',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'another page' => '/another-page',
    );
test_textframe( $document, $html, \@data, undef, \%links );


# check that links with ampersands are correctly encoded
$document = <<END;
        A basic link to <some search page>.

<some search page | /search?q=terms&submit=submit>
END
$html = <<HTML;
<p>A basic link to <a href='/search?q=terms&amp;submit=submit'>some search page</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'some search page',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'some search page' => '/search?q=terms&submit=submit',
    );
test_textframe( $document, $html, \@data, undef, \%links );


# test links that span lines are correctly parsed
$document = <<END;
        A basic link to <Google 
        | http://www.google.com/>.

END
$ref_doc = <<END;
        A basic link to <Google>.

<Google | http://www.google.com/>
END
$html = <<HTML;
<p>A basic link to <a href='http://www.google.com/'>Google</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'Google' => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test links that span lines are correctly parsed
$document = <<END;
        A basic link to <The 
        Google 
        Homepage 
        | 
            http://www.
            google.com/
        >.

END
$ref_doc = <<END;
        A basic link to <The Google Homepage>.

<The Google Homepage | http://www.google.com/>
END
$html = <<HTML;
<p>A basic link to <a href='http://www.google.com/'>The Google Homepage</a>.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'A basic link to ',
                },
                {
                    type => 'link',
                    text => 'The Google Homepage',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'The Google Homepage' => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );



# test links with braces are correctly parsed
$document = <<END;
        Tuesdays and Thursdays are when we have our <(not so) super-secret
        meetings> at work, so I have to go out early to grab a sandwich or
        miss out on lunch.

<(not so) super-secret meetings |
http://twitter.com/cackhanded/statuses/2630813
>
END
$html = <<HTML;
<p>Tuesdays and Thursdays are when we have our <a href='http://twitter.com/cackhanded/statuses/2630813'>(not so) super-secret meetings</a> at work, so I have to go out early to grab a sandwich or miss out on lunch.</p>
HTML
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'Tuesdays and Thursdays are when we have our ',
                },
                {
                    type => 'link',
                    text => '(not so) super-secret meetings',
                },
                {
                    type => 'string',
                    text => ' at work, so I have to go out early to grab a sandwich or miss out on lunch.',
                },
            ],
        },
    );
%links = (
        '(not so) super-secret meetings' 
            => 'http://twitter.com/cackhanded/statuses/2630813',
    );
test_textframe( $document, $html, \@data, undef, \%links );
