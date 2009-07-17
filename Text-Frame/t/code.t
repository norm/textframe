use strict;
use warnings;

use utf8;

use Test::More      tests => 80;
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
            metadata => {
                code_found => 1,
            },
            elements => [],
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
delete $html_data[1]{'metadata'}{'code_found'};
test_textframe( $document, $html, \@data, \@html_data, \%links );


# test a long code block
$document = <<END;
        First paragraph.

    « perl:
        # copy arguments over
        foreach my \$key ( keys \%metadata ) {
            \$details{ \$key } = \$metadata{ \$key };
        }
        
        # preserve original values
        KEY:
        foreach my \$key ( keys \%details ) {
            next KEY  if 'metadata' eq \$key;
        
            \$details{"original_\${key}"} = \$details{ \$key };
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

# preserve original values
KEY:
foreach my \$key ( keys \%details ) {
    next KEY  if 'metadata' eq \$key;

    \$details{"original_\${key}"} = \$details{ \$key };
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
            metadata => {
                code_found => 1,
            },
            elements => [],
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
delete $html_data[1]{'metadata'}{'code_found'};
test_textframe( $document, $html, \@data, \@html_data, \%links );


# test two blocks in the same document (a previous regression)
$document = <<END;

Textframe Markup

        Explaining textframe.

    «
        Textframe is another lightweight markup language.
    »

        The code is up on <github>.

    «
        Textframe is a codification of the way I have written plain text
        for many years.
        
            The source form of textframe documents is designed
            to look as meaningful and attractive as possible.
    »

<github | http://github.com/norm/textframe>
END
$html = <<HTML;
<h1>Textframe Markup</h1>
<p>Explaining textframe.</p>
<pre><code>Textframe is another lightweight markup language.
</code></pre>
<p>The code is up on <a href='http://github.com/norm/textframe'>github</a>.</p>
<pre><code>Textframe is a codification of the way I have written plain text
for many years.

    The source form of textframe documents is designed
    to look as meaningful and attractive as possible.
</code></pre>
HTML
@data = (
        {
          'elements' => [
                          {
                            'text' => 'Textframe Markup',
                            'type' => 'string'
                          }
                        ],
          'context' => [
                         'header',
                         'block'
                       ],
          'metadata' => {}
        },
        {
          'elements' => [
                          {
                            'text' => 'Explaining textframe.',
                            'type' => 'string'
                          }
                        ],
          'context' => [
                         'indent',
                         'indent',
                         'block'
                       ],
          'metadata' => {}
        },
        {
          'elements' => [],
          'context' => [
                         'indent',
                         'code',
                         'block'
                       ],
          'metadata' => {
                          'code_found' => 1
                        }
        },
        {
          'elements' => [
                          {
                            'text' => 'The code is up on ',
                            'type' => 'string'
                          },
                          {
                            'text' => 'github',
                            'type' => 'link'
                          },
                          {
                            'text' => '.',
                            'type' => 'string'
                          }
                        ],
          'context' => [
                         'indent',
                         'indent',
                         'block'
                       ],
          'metadata' => {}
        },
        {
          'elements' => [],
          'context' => [
                         'indent',
                         'code',
                         'block'
                       ],
          'metadata' => {
                          'code_found' => 1
                        }
        }
    );
%links = (
        github => 'http://github.com/norm/textframe',
    );
@html_data = @{ dclone( \@data ) };
delete $html_data[2]{'metadata'}{'code_found'};
delete $html_data[4]{'metadata'}{'code_found'};
test_textframe( $document, $html, \@data, \@html_data, \%links );
