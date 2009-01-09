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



# test nested emphasis within italics is parsed correctly
$document = <<END;
        A sentence with /some _very *deeply* nested_ emphasis/ in it.

END
$html = <<HTML;
<p>A sentence with <i>some <em>very <strong>deeply</strong> nested</em> emphasis</i> in it.</p>
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
                    text => 'some _very *deeply* nested_ emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some ',
                        },
                        {
                            type => 'emphasis',
                            text => 'very *deeply* nested',
                            contents => [
                                {
                                    type => 'string',
                                    text => 'very ',
                                },
                                {
                                    type => 'emphasis',
                                    text => 'deeply',
                                    contents => [
                                        {
                                            type => 'string',
                                            text => 'deeply',
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
                            text => ' emphasis',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' in it.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test nested italics and emphasis is parsed correctly
$document = <<END;
        A sentence with _some /very *deeply* nested/ emphasis_ in it.

END
$html = <<HTML;
<p>A sentence with <em>some <i>very <strong>deeply</strong> nested</i> emphasis</em> in it.</p>
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
                    type => 'emphasis',
                    text => 'some /very *deeply* nested/ emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some ',
                        },
                        {
                            type => 'italic',
                            text => 'very *deeply* nested',
                            contents => [
                                {
                                    type => 'string',
                                    text => 'very ',
                                },
                                {
                                    type => 'emphasis',
                                    text => 'deeply',
                                    contents => [
                                        {
                                            type => 'string',
                                            text => 'deeply',
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
                            text => ' emphasis',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' in it.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test an example that was previously interpreted as italics and emphasis
$document = <<END;
        Ignored comment blocks are started with the marker slash-star (/*) and
        end with star-slash (*/).

END
$html = <<HTML;
<p>Ignored comment blocks are started with the marker slash-star (/*) and end with star-slash (*/).</p>
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
                    text => 'Ignored comment blocks are started with the marker slash-star (/*) and end with star-slash (*/).',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );
