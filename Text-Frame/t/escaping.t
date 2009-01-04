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



# test a simple sentence with some raw text
$document = <<END;
        A sentence with some characters likely to interfere with HTML, but
        which could always be present in source, like 2 < 5, 10 > 5, AT&T, &
        something which has a spurious " character.

END
$html = <<HTML;
<p>A sentence with some characters likely to interfere with HTML, but which could always be present in source, like 2 &lt; 5, 10 &gt; 5, AT&amp;T, &amp; something which has a spurious &quot; character.</p>
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
                    text => 'A sentence with some characters likely to interfere with HTML, but which could always be present in source, like 2 < 5, 10 > 5, AT&T, & something which has a spurious " character.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test an example that was previously interpreted as a link to ", "
$document = <<END;
        In HTML, the angle brackets, ampersand and double-quote characters (<,
        >, & and ") are special. Textframe will automatically turn any of
        these in HTML output that are not related to HTML markup into their
        associated entities.

END
$html = <<HTML;
<p>In HTML, the angle brackets, ampersand and double-quote characters (&lt;, &gt;, &amp; and &quot;) are special. Textframe will automatically turn any of these in HTML output that are not related to HTML markup into their associated entities.</p>
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
                    text => 'In HTML, the angle brackets, ampersand and double-quote characters (<, >, & and ") are special. Textframe will automatically turn any of these in HTML output that are not related to HTML markup into their associated entities.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that text within code is still escaped
$document = <<END;
        An included comment is some text that should by preserved in the
        textframe output, either as another included comment or in HTML by
        surrounding it with «<!--» and «-->» markers.

END
$html = <<HTML;
<p>An included comment is some text that should by preserved in the textframe output, either as another included comment or in HTML by surrounding it with <code>&lt;!--</code> and <code>--&gt;</code> markers.</p>
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
                    text => 'An included comment is some text that should by preserved in the textframe output, either as another included comment or in HTML by surrounding it with ',
                },
                {
                    type => 'code',
                    text => '<!--',
                },
                {
                    type => 'string',
                    text => ' and ',
                },
                {
                    type => 'code',
                    text => '-->',
                },
                {
                    type => 'string',
                    text => ' markers.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );
