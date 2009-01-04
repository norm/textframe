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



# test a simple two item numbered list
$document = <<END;
    #.  This document has a numbered list.

    #.  It has two items, and starts at one.

END
$ref_doc = <<END;
    1.  This document has a numbered list.

    2.  It has two items, and starts at one.

END
$html = <<HTML;
<ol>
  <li><p>This document has a numbered list.</p></li>
  <li><p>It has two items, and starts at one.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '#',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a numbered list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '#',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'It has two items, and starts at one.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test a simple list that starts at a value other than 1
$document = <<END;
    4.  This document has a numbered list.

    #.  It has two items, and starts at four.

END
$ref_doc = <<END;
    4.  This document has a numbered list.

    5.  It has two items, and starts at four.

END
$html = <<HTML;
<ol start='4'>
  <li><p>This document has a numbered list.</p></li>
  <li><p>It has two items, and starts at four.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '4',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a numbered list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '#',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'It has two items, and starts at four.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# check that automatic numbering is actually enforced
$document = <<END;
    1.  This document has a numbered list.

    10. It has three items, and starts at one.

    11. Third item should be 3, since only the first number in a list is
        significant.

END
$ref_doc = <<END;
    1.  This document has a numbered list.

    2.  It has three items, and starts at one.

    3.  Third item should be 3, since only the first number in a list is
        significant.

END
$html = <<HTML;
<ol>
  <li><p>This document has a numbered list.</p></li>
  <li><p>It has three items, and starts at one.</p></li>
  <li><p>Third item should be 3, since only the first number in a list is significant.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a numbered list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '10',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'It has three items, and starts at one.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '11',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Third item should be 3, since only the first number in a list is significant.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test that a paragraph between list items breaks it up
$document = <<END;
    3.  This document has two numbered lists.

        It has a paragraph between them.

    2.  Each list has one item and starts as 1.

END
$html = <<HTML;
<ol start='3'>
  <li><p>This document has two numbered lists.</p></li>
</ol>
<p>It has a paragraph between them.</p>
<ol start='2'>
  <li><p>Each list has one item and starts as 1.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '3',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has two numbered lists.',
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
                    text => 'It has a paragraph between them.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Each list has one item and starts as 1.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that sub lists work
$document = <<END;
    1.  This document has a nested numbered list.

        1.  This is the sub item.

        2.  Second sub item.

    2.  Back to the main list, and should be numbered two.

END
$html = <<HTML;
<ol>
  <li><p>This document has a nested numbered list.</p>
  <ol>
    <li><p>This is the sub item.</p></li>
    <li><p>Second sub item.</p></li>
  </ol>
  </li>
  <li><p>Back to the main list, and should be numbered two.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a nested numbered list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This is the sub item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Second sub item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Back to the main list, and should be numbered two.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that prematurely closing lists work
$document = <<END;
    1.  This document has more nested numbered lists.

        1.  This is the sub item.

            1.  This is the sub sub item.

        2.  Back to the sub list.

END
$html = <<HTML;
<ol>
  <li><p>This document has more nested numbered lists.</p>
  <ol>
    <li><p>This is the sub item.</p>
    <ol>
      <li><p>This is the sub sub item.</p></li>
    </ol>
    </li>
    <li><p>Back to the sub list.</p></li>
  </ol>
  </li>
  </ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has more nested numbered lists.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This is the sub item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This is the sub sub item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Back to the sub list.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that sub sub lists work
$document = <<END;
    1.  This document has a nested numbered list.

        1.  This is the sub item.

            1.  Second sub list, first item.

            2.  Second sub list, second item.

        2.  First sub list, second item.

            1.  Third sub list, first item.

            2.  Third sub list, second item.

        3.  First sub list, third item.

    2.  Back to the main list, and should be numbered two.

END
$html = <<HTML;
<ol>
  <li><p>This document has a nested numbered list.</p>
  <ol>
    <li><p>This is the sub item.</p>
    <ol>
      <li><p>Second sub list, first item.</p></li>
      <li><p>Second sub list, second item.</p></li>
    </ol>
    </li>
    <li><p>First sub list, second item.</p>
    <ol>
      <li><p>Third sub list, first item.</p></li>
      <li><p>Third sub list, second item.</p></li>
    </ol>
    </li>
    <li><p>First sub list, third item.</p></li>
  </ol>
  </li>
  <li><p>Back to the main list, and should be numbered two.</p></li>
</ol>
HTML
@data = (
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a nested numbered list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'This is the sub item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Second sub list, first item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Second sub list, second item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'First sub list, second item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '1',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Third sub list, first item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Third sub list, second item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '3',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'First sub list, third item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'number',
                'block',
            ],
            metadata => {
                list_number => '2',
                no_header   => '1',
            },
            elements => [
                {
                    type => 'string',
                    text => 'Back to the main list, and should be numbered two.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test opening too many lists by using bad indents
# TODO