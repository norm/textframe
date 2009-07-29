use strict;
use warnings;

use utf8;

use Test::More      tests => 28;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test a simple sentence with some raw text
$document = <<END;
        A sentence with |raw| text.

END
$html = <<HTML;
<p>A sentence with raw text.</p>
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
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test a simple sentence with two pieces of raw text
$document = <<END;
        A sentence with |two| little |bits of| raw text.

END
$html = <<HTML;
<p>A sentence with two little bits of raw text.</p>
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
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test that emphasis within raw is not parsed
$document = <<END;
        A sentence with |raw *not* emphasised text|.

END
$html = <<HTML;
<p>A sentence with raw *not* emphasised text.</p>
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
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test that links within raw are not parsed
$document = <<END;
        A sentence with |raw <em>not linked</em> text|.

END
$html = <<HTML;
<p>A sentence with raw <em>not linked</em> text.</p>
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
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test that code within raw is not parsed
$document = <<END;
        A sentence with |raw «not code» text|.

END
$html = <<HTML;
<p>A sentence with raw «not code» text.</p>
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
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test raw blocks
$document = <<END;
        First paragraph.
        
    |   <div id='spesh'>In this section,
    |       white space is ignored,
    |           but no other interpolation
    |   occurs.</div>
 
        Second paragraph.

END
$ref_doc = <<END;
        First paragraph.

    |   <div id='spesh'>In this section, white space is ignored, but no other
    |   interpolation occurs.</div>

        Second paragraph.

END
$html = <<HTML;
<p>First paragraph.</p>
<div id='spesh'>In this section, white space is ignored, but no other interpolation occurs.</div>
<p>Second paragraph.</p>
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
                    text => 'First paragraph.',
                },
            ],
        },
        {
            context => [
                'indent',
                'raw',
                'block',
            ],
            metadata => {},
            elements => [],
        },
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
                    text => 'Second paragraph.',
                },
            ],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $ref_doc,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,
    } );


# test multiple raw blocks
$document = <<END;
    |   <div>

        Wrapping a div around a paragraph.

    |   </div>

END
$html = <<HTML;
<div>
<p>Wrapping a div around a paragraph.</p>
</div>
HTML
@data = (
        {
            context => [
                'indent',
                'raw',
                'block',
            ],
            metadata => {},
            elements => [],
        },
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
                    text => 'Wrapping a div around a paragraph.',
                },
            ],
        },
        {
            context => [
                'indent',
                'raw',
                'block',
            ],
            metadata => {},
            elements => [],
        },
    );
%links = ();
test_textframe( {
        input           => $document,
        text            => $document,
        html            => $html,
        data            => \@data,
        links           => \%links,
        skip_html_tests => 1,       # no support for raw in html sources
    } );
