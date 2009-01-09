use strict;
use warnings;

use utf8;

use Test::More      tests => 64;
require 't/testing.pl';

use Storable        qw( dclone );
use Text::Frame;



my $document;
my $html;
my @data;
my @html_data;
my %links;
my $ref_doc;



# test simple code string embedding, with both marker types
$document = <<END;
        A sentence with «some» code.

END
$ref_doc = $document;
$html = <<HTML;
<p>A sentence with <code>some</code> code.</p>
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
test_textframe( $document, $html, \@data, undef, \%links );
$document = <<END;
        A sentence with <<some>> code.

END
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test two code strings work correctly, with both marker types
$document = <<END;
        A sentence with «two» little «bits of» code.

END
$ref_doc = $document;
$html = <<HTML;
<p>A sentence with <code>two</code> little <code>bits of</code> code.</p>
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
test_textframe( $document, $html, \@data, undef, \%links );
$document = <<END;
        A sentence with <<two>> little <<bits of>> code.

END
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );
$document = <<END;
        A sentence with «two» little <<bits of>> code.

END
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );
$document = <<END;
        A sentence with <<two>> little «bits of» code.

END
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test an example that was previously interpreted incorrectly
$document = <<END;
        A block of text to be treated as a raw block and where white space is
        treated as significant is marked by having double guillemets (<<«>>
        and <<»>>) or double angle brackets («<<» and «>>») alone on lines
        immediately before and after the block.

END
$ref_doc = $document;
$html = <<HTML;
<p>A block of text to be treated as a raw block and where white space is treated as significant is marked by having double guillemets (<code>«</code> and <code>»</code>) or double angle brackets (<code>&lt;&lt;</code> and <code>&gt;&gt;</code>) alone on lines immediately before and after the block.</p>
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
                    text => 'A block of text to be treated as a raw block and where white space is treated as significant is marked by having double guillemets (',
                },
                {
                    type => 'code',
                    text => '«',
                },
                {
                    type => 'string',
                    text => ' and ',
                },
                {
                    type => 'code',
                    text => '»',
                },
                {
                    type => 'string',
                    text => ') or double angle brackets (',
                },
                {
                    type => 'code',
                    text => '<<',
                },
                {
                    type => 'string',
                    text => ' and ',
                },
                {
                    type => 'code',
                    text => '>>',
                },
                {
                    type => 'string',
                    text => ') alone on lines immediately before and after the block.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test a simple code block, with both marker types
$document = <<END;
        First paragraph.

    « perl:
        # copy arguments over
        foreach my \$key ( keys \%metadata ) {
            \$details{ \$key } = \$metadata{ \$key };
        }
    »

        Second paragraph.

END
$html = <<HTML;
<p>First paragraph.</p>
<pre><code class='perl'># copy arguments over
foreach my \$key ( keys \%metadata ) {
    \$details{ \$key } = \$metadata{ \$key };
}
</code></pre>
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
                'code',
                'block',
            ],
            metadata => {},
            elements => [
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
            elements => [
                {
                    type => 'string',
                    text => 'Second paragraph.',
                },
            ],
        },
    );
%links = ();
@html_data = @{ dclone( \@data ) };
delete $html_data[1]{'elements'}[0];
test_textframe( $document, $html, \@data, \@html_data, \%links );
