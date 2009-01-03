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



# test a simple sentence with some raw text
$document = <<END;
        A sentence with |raw| text.

END
$html        
    = qq(<p>A sentence with raw text.</p>\n);
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
test_textframe( $document, $html, \@data, \%links );


# test a simple sentence with two pieces of raw text
$document = <<END;
        A sentence with |two| little |bits of| raw text.

END
$html        
    = qq(<p>A sentence with two little bits of raw text.</p>\n);
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
test_textframe( $document, $html, \@data, \%links );


# test that emphasis within raw is not parsed
$document = <<END;
        A sentence with |raw *not* emphasised text|.

END
$html        
    = qq(<p>A sentence with raw *not* emphasised text.</p>\n);
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
test_textframe( $document, $html, \@data, \%links );


# test that links within raw are not parsed
$document = <<END;
        A sentence with |raw <em>not linked</em> text|.

END
$html        
    = qq(<p>A sentence with raw <em>not linked</em> text.</p>\n);
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
test_textframe( $document, $html, \@data, \%links );


# test that code within raw is not parsed
$document = <<END;
        A sentence with |raw «not code» text|.

END
$html = <<END;
<p>A sentence with raw «not code» text.</p>
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
test_textframe( $document, $html, \@data, \%links );


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
$html = <<END;
<p>First paragraph.</p>
<div id='spesh'>In this section, white space is ignored, but no other interpolation occurs.</div>
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
                'raw',
                'block',
            ],
            metadata => {},
            text => [
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
