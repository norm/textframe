use strict;
use warnings;

use utf8;

use Test::More      tests => 12;
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
$html = <<END;
<p>First paragraph.</p>
<p>Second paragraph.</p>
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
            text => [
                {
                    type => 'string',
                    text => 'Second paragraph.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


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
$html = <<END;
<p>First paragraph.</p>
<p><i>* This is not completely * ignored. *</i></p>
<p>Second paragraph.</p>
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
            text => [
                {
                    type => 'string',
                    text => '',
                },
                {
                    type => 'italic',
                    text => '* This is not completely * ignored. *',
                    contents => [
                        {
                            type => 'string',
                            text => '* This is not completely * ignored. *'
                        }
                    ],
                },
                {
                    type => 'string',
                    text => '',
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
            text => [
                {
                    type => 'string',
                    text => 'Second paragraph.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


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
$html = <<END;
<p>First paragraph.</p>
<!-- This is not completely ignored. -->
<p>Second paragraph.</p>
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
            text => [
                {
                    type => 'string',
                    text => 'This is not completely ignored.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );
