use strict;
use warnings;

use Test::More      tests => 24;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test italic text is parsed correctly
$document = <<END;
        A sentence with some ''quoted text''.

END
$html = <<HTML;
<p>A sentence with some <q>quoted text</q>.</p>
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
                    text => 'A sentence with some ',
                },
                {
                    type => 'quote',
                    text => 'quoted text',
                    contents => [
                        {
                            type => 'string',
                            text => 'quoted text',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test two parts of italic text is parsed correctly
$document = <<END;
        A sentence with two ''little'' bits of ''quoted text''.

END
$html = <<HTML;
<p>A sentence with two <q>little</q> bits of <q>quoted text</q>.</p>
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
                    text => 'A sentence with two ',
                },
                {
                    type => 'quote',
                    text => 'little',
                    contents => [
                        {
                            type => 'string',
                            text => 'little',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' bits of ',
                },
                {
                    type => 'quote',
                    text => 'quoted text',
                    contents => [
                        {
                            type => 'string',
                            text => 'quoted text',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test italic text that wraps across lines is parsed correctly
$document = <<END;
        A sentence with ''wrapping 
        quoted'' text.

END
$ref_doc = <<END;
        A sentence with ''wrapping quoted'' text.

END
$html = <<HTML;
<p>A sentence with <q>wrapping quoted</q> text.</p>
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
                    type => 'quote',
                    text => 'wrapping quoted',
                    contents => [
                        {
                            type => 'string',
                            text => 'wrapping quoted',
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
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );
