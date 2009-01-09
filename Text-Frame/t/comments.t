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



# test ignored comments
$document = <<END;
        First paragraph.
        
/* This is completely
 * ignored.
 */
 
        Second paragraph.

END
$ref_doc = <<END;
        First paragraph.

        Second paragraph.

END
$html = <<HTML;
<p>First paragraph.</p>
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
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test comments still work within normal body text.
$document = <<END;
        First paragraph.
        
        /* This is not completely
         * ignored.
         */
 
        Second paragraph.

END
$ref_doc = <<END;
        First paragraph.

        /* This is not completely * ignored. */

        Second paragraph.

END
$html = <<HTML;
<p>First paragraph.</p>
<p>/* This is not completely * ignored. */</p>
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
                'indent',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => '/* This is not completely * ignored. */',
                },
            ],
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
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test comments still work within normal body text.
$document = <<END;
        First paragraph.
        
    #   This is not completely
    #   ignored.
 
        Second paragraph.

END
$ref_doc = <<END;
        First paragraph.

    #   This is not completely ignored.

        Second paragraph.

END
$html = <<HTML;
<p>First paragraph.</p>
<!-- This is not completely ignored. -->
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
                'comment',
                'block',
            ],
            metadata => {},
            elements => [
                {
                    type => 'string',
                    text => 'This is not completely ignored.',
                },
            ],
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
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );
