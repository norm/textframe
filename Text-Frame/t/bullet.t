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



# test a simple two item bulleted list
$document = <<END;
    *   This document has a bulleted list.

    *   It has two items.

END
$html = <<HTML;
<ul>
  <li><p>This document has a bulleted list.</p></li>
  <li><p>It has two items.</p></li>
</ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a bulleted list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'It has two items.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that very simple lists don't become headers
$document = <<END;
    *   first item

    *   second item

END
$html = <<HTML;
<ul>
  <li><p>first item</p></li>
  <li><p>second item</p></li>
</ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'first item',
                },
            ],
        },
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'second item',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that a paragraph between list items breaks it up
$document = <<END;
    *   This document has two bulleted lists.

        It has a paragraph between them.

    *   Each list has one item.

END
$html = <<HTML;
<ul>
  <li><p>This document has two bulleted lists.</p></li>
</ul>
<p>It has a paragraph between them.</p>
<ul>
  <li><p>Each list has one item.</p></li>
</ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has two bulleted lists.',
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
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'Each list has one item.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that sub lists work
$document = <<END;
    *   This document has a nested bulleted list.

        *   This is the sub item.

    *   Back to the main list.

END
$html = <<HTML;
<ul>
  <li><p>This document has a nested bulleted list.</p>
  <ul>
    <li><p>This is the sub item.</p></li>
  </ul>
  </li>
  <li><p>Back to the main list.</p></li>
</ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has a nested bulleted list.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
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
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'Back to the main list.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that sub sub lists work
$document = <<END;
    *   This document has more nested bulleted lists.

        *   This is the sub item.

            *   This is the sub sub item.

        *   Back to the sub list.

END
$html = <<HTML;
<ul>
  <li><p>This document has more nested bulleted lists.</p>
  <ul>
    <li><p>This is the sub item.</p>
    <ul>
      <li><p>This is the sub sub item.</p></li>
    </ul>
    </li>
    <li><p>Back to the sub list.</p></li>
  </ul>
  </li>
  </ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'This document has more nested bulleted lists.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
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
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
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
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
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


# fairly complex nested lists
$document = <<END;
    *   List item.

        *   List item.

            *   List item.

                *   List item.

    *   List item.

        *   List item.

        *   List item.

            *   List item.

        *   List item.

    *   List item.

END
$html = <<HTML;
<ul>
  <li><p>List item.</p>
  <ul>
    <li><p>List item.</p>
    <ul>
      <li><p>List item.</p>
      <ul>
        <li><p>List item.</p></li>
      </ul>
      </li>
      </ul>
      </li>
      </ul>
      </li>
  <li><p>List item.</p>
  <ul>
    <li><p>List item.</p></li>
    <li><p>List item.</p>
    <ul>
      <li><p>List item.</p></li>
    </ul>
    </li>
    <li><p>List item.</p></li>
  </ul>
  </li>
  <li><p>List item.</p></li>
</ul>
HTML
@data = (
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
        {
            context => [
                'indent',
                'bullet',
                'block',
            ],
            metadata => {
                no_header => 1,
            },
            elements => [
                {
                    type => 'string',
                    text => 'List item.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test opening too many lists by using bad indents
# TODO
