use strict;
use warnings;

use Test::More      tests => 48;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test italic text is parsed correctly
$document = <<END;
        A sentence with _some emphasis_.

END
$ref_doc = $document;
$html    = <<END;
<p>A sentence with <em>some emphasis</em>.</p>
END
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'A sentence with ',
                },
                {
                    type => 'emphasis',
                    text => 'some emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some emphasis',
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
%links = (
    );
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence with *some emphasis*.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test that wrapping doesn't break emphasis
$document = <<END;
        A sentence with _some 
        emphasis_.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
        A sentence with *some 
        emphasis*.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test that the emphasis module correctly uses underscores in generated
# document again (rather than stupidly switching to asterisks)
$document = <<END;
        A sentence with _some emphasis_ and _some more emphasis_.

END
$ref_doc = $document;
$html    = <<END;
<p>A sentence with <em>some emphasis</em> and <em>some more emphasis</em>.</p>
END
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'A sentence with ',
                },
                {
                    type => 'emphasis',
                    text => 'some emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some emphasis',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' and ',
                },
                {
                    type => 'emphasis',
                    text => 'some more emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some more emphasis',
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
%links = (
    );
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence with *some emphasis* and *some more emphasis*.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
        A sentence with _some emphasis_ and *some more emphasis*.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
        A sentence with *some emphasis* and _some more emphasis_.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test nested emphasis creates strong in HTML and uses asterisks in text
$document = <<END;
        A sentence with _some *nested* emphasis_.

END
$ref_doc = $document;
$html    = <<END;
<p>A sentence with <em>some <strong>nested</strong> emphasis</em>.</p>
END
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'A sentence with ',
                },
                {
                    type => 'emphasis',
                    text => 'some *nested* emphasis',
                    contents => [
                        {
                            type => 'string',
                            text => 'some ',
                        },
                        {
                            type => 'emphasis',
                            text => 'nested',
                            contents => [
                                {
                                    type => 'string',
                                    text => 'nested',
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
                    text => '.',
                },
            ],
        },
    );
%links = (
    );
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence with *some _nested_ emphasis*.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# prove that three levels of emphasis does not work
$document = <<END;
        A sentence _with *three _levels_ of* emphasis_ cannot work.

END
$html    = <<END;
<p>A sentence <em>with *three _levels</em> of* emphasis_ cannot work.</p>
END
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'A sentence ',
                },
                {
                    type     => 'emphasis',
                    text     => 'with *three _levels',
                    contents => [
                        {
                            type => 'string',
                            text => 'with *three _levels',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' of* emphasis_ cannot work.',
                },
            ],
        },
    );
%links = (
    );
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence *with _three *levels* of_ emphasis* cannot work.

END
$ref_doc = <<END;
        A sentence _with _three *levels_ of_ emphasis* cannot work.

END
$html    = <<END;
<p>A sentence <em>with _three *levels</em> of_ emphasis* cannot work.</p>
END
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'A sentence ',
                },
                {
                    type     => 'emphasis',
                    text     => 'with _three *levels',
                    contents => [
                        {
                            type => 'string',
                            text => 'with _three *levels',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' of_ emphasis* cannot work.',
                },
            ],
        },
    );
test_textframe( $document, $html, \@data, \%links, $ref_doc );
