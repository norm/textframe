use strict;
use warnings;

use utf8;

use Test::More      tests => 24;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test simple code string embedding, with both marker types
$document = <<END;
        A sentence with «some» code.

END
$ref_doc = $document;
$html = <<END;
<p>A sentence with <code>some</code> code.</p>
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
                    type => 'code',
                    text => 'some',
                },
                {
                    type => 'string',
                    text => ' code.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence with <<some>> code.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test two code strings work correctly, with both marker types
$document = <<END;
        A sentence with «two» little «bits of» code.

END
$ref_doc = $document;
$html = <<END;
<p>A sentence with <code>two</code> little <code>bits of</code> code.</p>
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
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );
$document = <<END;
        A sentence with <<two>> little <<bits of>> code.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
        A sentence with «two» little <<bits of>> code.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
        A sentence with <<two>> little «bits of» code.

END
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test a simple code block, with both marker types
# TODO
