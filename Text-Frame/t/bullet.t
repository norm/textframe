use strict;
use warnings;

use utf8;

use Test::More      tests => 56;
require 't/testing.pl';

use Text::Frame;

use Storable    qw( dclone );


my $document;
my $html;
my @data;
my @html_data;
my %links;
my $ref_doc;



# test a simple two item bulleted list
$document = <<END;
    •   This document has a bulleted list.

    •   It has two items.

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
@html_data = @{ dclone( \@data ) };
$html_data[0]{'metadata'} = {};
$html_data[1]{'metadata'} = {};
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test different bullet symbols
$document = <<END;
    *   This document has a bulleted list.

    o   It has five items.

    .   Each uses a different symbol.

    -   Textframe can mix and match symbols.

    •   Generated documents will always use this symbol (middle dot).

END
$ref_doc = <<END;
    •   This document has a bulleted list.

    •   It has five items.

    •   Each uses a different symbol.

    •   Textframe can mix and match symbols.

    •   Generated documents will always use this symbol (middle dot).

END
$html = <<HTML;
<ul>
  <li><p>This document has a bulleted list.</p></li>
  <li><p>It has five items.</p></li>
  <li><p>Each uses a different symbol.</p></li>
  <li><p>Textframe can mix and match symbols.</p></li>
  <li><p>Generated documents will always use this symbol (middle dot).</p></li>
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
                    text => 'It has five items.',
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
                    text => 'Each uses a different symbol.',
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
                    text => 'Textframe can mix and match symbols.',
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
                    text => 'Generated documents will always use this symbol (middle dot).',
                },
            ],
        },
    );
%links = ();
@html_data = @{ dclone( \@data ) };
foreach my $index ( 0 .. 4 ) {
    $html_data[ $index ]{'metadata'} = {};
}
test_textframe( {
        input      => $document,
        text       => $ref_doc,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test that very simple lists don't become headers
$document = <<END;
    •   first item

    •   second item

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
@html_data = @{ dclone( \@data ) };
$html_data[0]{'metadata'} = {};
$html_data[1]{'metadata'} = {};
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test that a paragraph between list items breaks it up
$document = <<END;
    •   This document has two bulleted lists.

        It has a paragraph between them.

    •   Each list has one item.

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
@html_data = @{ dclone( \@data ) };
$html_data[0]{'metadata'} = {};
$html_data[1]{'metadata'} = {};
$html_data[2]{'metadata'} = {};
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test that sub lists work
$document = <<END;
    •   This document has a nested bulleted list.

        •   This is the sub item.

    •   Back to the main list.

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
@html_data = @{ dclone( \@data ) };
$html_data[0]{'metadata'} = {};
$html_data[1]{'metadata'} = {};
$html_data[2]{'metadata'} = {};
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test that sub sub lists work
$document = <<END;
    •   This document has more nested bulleted lists.

        •   This is the sub item.

            •   This is the sub sub item.

        •   Back to the sub list.

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
@html_data = @{ dclone( \@data ) };
$html_data[0]{'metadata'} = {};
$html_data[1]{'metadata'} = {};
$html_data[2]{'metadata'} = {};
$html_data[3]{'metadata'} = {};
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# fairly complex nested lists
$document = <<END;
    •   List item.

        •   List item.

            •   List item.

                •   List item.

    •   List item.

        •   List item.

        •   List item.

            •   List item.

        •   List item.

    •   List item.

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
@html_data = @{ dclone( \@data ) };
for my $i ( 0 .. 9 ) {
    $html_data[ $i ]{'metadata'} = {};
}
test_textframe( {
        input      => $document,
        text       => $document,
        html       => $html,
        data       => \@data,
        html_data  => \@html_data,
        links      => \%links,
    } );


# test opening too many lists by using bad indents
# TODO
