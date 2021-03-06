use strict;
use warnings;

use charnames qw( :full );

use Test::More      tests => 48;
require 't/testing.pl';

use Storable        qw( dclone );
use Text::Frame;



my $document;
my $html;
my @data;
my @html_data;
my %links;
my %html_links;
my $ref_doc;


# test basic referential # links
$document = <<END;
        This document has a link to the <Google> search engine. But the URI of
        the link is postponed until later for readability.

<Google | http://www.google.com/>
END
$html = <<HTML;
<p>This document has a link to the <a href='http://www.google.com/'>Google</a> search engine. But the URI of the link is postponed until later for readability.</p>
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
                    text => 'This document has a link to the ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => ' search engine. But the URI of the link'
                          . ' is postponed until later for readability.'
                },
            ],
        },
    );
%links = (
        'Google' => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links );


# test both lengthy referential links, and wrapping in the link text
$document = <<END;
        This document has a link to an article <Five Simple Steps>. But the
        URI of the link is postponed until later for readability.

<Five Simple Steps |
http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/
>
END
$html = <<HTML;
<p>This document has a link to an article <a href='http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/'>Five Simple Steps</a>. But the URI of the link is postponed until later for readability.</p>
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
                    text => 'This document has a link to an article ',
                },
                {
                    type => 'link',
                    text => "Five Simple Steps",
                },
                {
                    type => 'string',
                    text => '. But the URI of the link'
                          . ' is postponed until later for readability.'
                },
            ],
        },
    );
%links       = (
        "Five Simple Steps" => 'http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/',
    );
test_textframe( $document, $html, \@data, undef, \%links );


# test that reference links correctly expand out (even if the result would
# then not be able to be parsed correctly - as reference links can be
# anywhere, but generated documents have them at the end)
$document = <<END;
        This block has a reference link to <Google>.

<Google | http://www.google.com/>

        This block has a different link to 
        <Google | http://www.google.co.uk/>.

        Last block also links to <Google>. But which?
END
$ref_doc = <<END;
        This block has a reference link to <Google>.

        This block has a different link to <Google |
        http://www.google.co.uk/>.

        Last block also links to <Google>. But which?

<Google | http://www.google.com/>
END
$html = <<HTML;
<p>This block has a reference link to <a href='http://www.google.com/'>Google</a>.</p>
<p>This block has a different link to <a href='http://www.google.co.uk/'>Google</a>.</p>
<p>Last block also links to <a href='http://www.google.com/'>Google</a>. But which?</p>
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
                    text => 'This block has a reference link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => '.'
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
                    text => 'This block has a different link to ',
                },
                {
                    type => 'link',
                    text => "Google",
                    uri  => 'http://www.google.co.uk/',
                },
                {
                    type => 'string',
                    text => '.',
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
                    text => 'Last block also links to ',
                },
                {
                    type => 'link',
                    text => "Google",
                },
                {
                    type => 'string',
                    text => '. But which?',
                },
            ],
        },
    );
%links       = (
        "Google" => 'http://www.google.com/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test that reference links with shared link text are correctly
# overwritten by intermediate links with the same shared link text
$document = <<END;
        This block has a reference link to <Google>. But which?

        This block has a different link to 
        <Google | http://www.google.co.uk/>.

<Google | http://www.google.com/>
END
$ref_doc = <<END;
        This block has a reference link to <Google>. But which?

        This block has a different link to <Google>.

<Google | http://www.google.co.uk/>
END
$html = <<HTML;
<p>This block has a reference link to <a href='http://www.google.co.uk/'>Google</a>. But which?</p>
<p>This block has a different link to <a href='http://www.google.co.uk/'>Google</a>.</p>
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
                    text => 'This block has a reference link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => '. But which?',
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
                    text => 'This block has a different link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                },
                {
                    type => 'string',
                    text => '.',
                },
            ],
        },
    );
%links = (
        'Google' => 'http://www.google.co.uk/',
    );
test_textframe( $document, $html, \@data, undef, \%links, $ref_doc );


# test that multiple unused reference links produce no output
$document = <<END;
        The symbol used does not affect the document in any way. Generated
        textframe documents will always use an asterisk.

<Mark Boulton's Five Simple Steps | 
    http://www.markboulton.co.uk/journal/comments/
    five_simple_steps_to_better_typography_part_2/
>
<RFC 2396 | http://www.ietf.org/rfc/rfc2396.txt>
END
$ref_doc = <<END;
        The symbol used does not affect the document in any way. Generated
        textframe documents will always use an asterisk.

END
$html = <<HTML;
<p>The symbol used does not affect the document in any way. Generated textframe documents will always use an asterisk.</p>
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
                    text => 'The symbol used does not affect the document in any way. Generated textframe documents will always use an asterisk.',
                },
            ],
        },
    );
%links = (
        "Mark Boulton's Five Simple Steps" => 'http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/',
        'RFC 2396' => 'http://www.ietf.org/rfc/rfc2396.txt',
    );
%html_links = ();
test_textframe( {
        input          => $document,
        text_text      => $ref_doc,
        html           => $html,
        html_text      => $ref_doc,
        data           => \@data,
        links          => \%links,
        html_links     => \%html_links,
    } );


# test that html links with the same name but different whitespace are 
# not seen as different (but then end up being the same when converted to
# textframe and back to HTML)
$document = <<END;
        This block links to the <Google homepage>.

        This block also links to the <Google 
        homepage>.

<Google homepage | http://www.google.com/>
END
$ref_doc = <<END;
        This block links to the <Google homepage>.

        This block also links to the <Google homepage>.

<Google homepage | http://www.google.com/>
END
$html = <<HTML;
<p>This block links to the <a href='http://www.google.com/'>Google homepage</a>.</p>
<p>This block also links to the <a href='http://www.google.com/'>Google homepage</a>.</p>
HTML
my $check_html = <<HTML;
<p>This block links to the <a href='http://www.google.com/'>Google homepage</a>.</p>
<p>This block also links to the <a 
    href='http://www.google.com/'>Google 
    homepage</a>.</p>

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
                    text => 'This block links to the ',
                },
                {
                    type => 'link',
                    text => 'Google homepage',
                },
                {
                    type => 'string',
                    text => '.'
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
                    text => 'This block also links to the ',
                },
                {
                    type => 'link',
                    text => 'Google homepage',
                },
                {
                    type => 'string',
                    text => '.'
                },
            ],
        },
    );
%links       = (
        "Google homepage" => 'http://www.google.com/',
    );
test_textframe( {
        input      => $document,
        text       => $ref_doc,
        html       => $html,
        html_input => $check_html,
        data       => \@data,
        links      => \%links,
    } );
