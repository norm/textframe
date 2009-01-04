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



# test struck text is parsed correctly
$document = <<END;
        A sentence with --some-- struck text.

END
$html = <<HTML;
<p>A sentence with <strike>some</strike> struck text.</p>
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
                    type => 'struck',
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
                    text => ' struck text.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test two parts of struck text is parsed correctly
$document = <<END;
        A sentence with --two-- little --bits of-- struck text.

END
$html = <<HTML;
<p>A sentence with <strike>two</strike> little <strike>bits of</strike> struck text.</p>
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
                    type => 'struck',
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
                    type => 'struck',
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
                    text => ' struck text.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test struck text that wraps across lines is parsed correctly
$document = <<END;
        A sentence with --wrapping 
        struck-- text.

END
$ref_doc = <<END;
        A sentence with --wrapping struck-- text.

END
$html = <<HTML;
<p>A sentence with <strike>wrapping struck</strike> text.</p>
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
                    type => 'struck',
                    text => 'wrapping struck',
                    contents => [
                        {
                            type => 'string',
                            text => 'wrapping struck',
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
