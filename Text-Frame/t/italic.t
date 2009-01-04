use strict;
use warnings;

use Test::More      tests => 12;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test italic text is parsed correctly
$document = <<END;
        A sentence with /some/ italic text.

END
$html = <<HTML;
<p>A sentence with <i>some</i> italic text.</p>
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
                    type => 'italic',
                    text => 'some',
                    contents => [
                        {
                            type => 'string',
                            text => 'some',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' italic text.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test two parts of italic text is parsed correctly
$document = <<END;
        A sentence with /two/ little /bits of/ italic text.

END
$html = <<HTML;
<p>A sentence with <i>two</i> little <i>bits of</i> italic text.</p>
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
                    type => 'italic',
                    text => 'two',
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
                    type => 'italic',
                    text => 'bits of',
                    contents => [
                        {
                            type => 'string',
                            text => 'bits of',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' italic text.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test italic text that wraps across lines is parsed correctly
$document = <<END;
        A sentence with /wrapping 
        italic/ text.

END
$ref_doc = <<END;
        A sentence with /wrapping italic/ text.

END
$html = <<HTML;
<p>A sentence with <i>wrapping italic</i> text.</p>
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
                    type => 'italic',
                    text => 'wrapping italic',
                    contents => [
                        {
                            type => 'string',
                            text => 'wrapping italic',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' text.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );
