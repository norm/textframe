use strict;
use warnings;

use Test::More      tests => 24;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my @ref_data;
my %links;
my $ref_doc;


# test links are parsed correctly
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
