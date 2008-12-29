use strict;
use warnings;

use Test::More      tests => 16;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;


# test basic referential links
$document = <<END;
        This document has a link to the <Google> search engine. But the URI of
        the link is postponed until later for readability.

<Google | http://www.google.com/>
END
$html        
    = q(<p>This document has a link to the <a)
    . q( href='http://www.google.com/'>Google</a> search engine. But the)
    . q( URI of the link is postponed until later for)
    . qq( readability.</p>\n);
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            text => [
                {
                    type => 'string',
                    text => 'This document has a link to the ',
                },
                {
                    type => 'link',
                    text => 'Google',
                    uri  => '',
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
test_textframe( $document, $html, \@data, \%links );


# test both lengthy referential links, and wrapping in the link text
$document = <<END;
        This document has a link to an article <Mark Boulton's Five Simple
        Steps>. But the URI of the link is postponed until later for
        readability.

<Mark Boulton's Five Simple Steps |
http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/
>
END
$html        
    = q(<p>This document has a link to an article <a)
    . q( href='http://www.markboulton.co.uk/journal/comments/)
    . q(five_simple_steps_to_better_typography_part_2/'>Mark)
    . q( Boulton's Five Simple Steps</a>. But the)
    . q( URI of the link is postponed until later for)
    . qq( readability.</p>\n);
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            text => [
                {
                    type => 'string',
                    text => 'This document has a link to an article ',
                },
                {
                    type => 'link',
                    text => "Mark Boulton's Five Simple Steps",
                    uri  => '',
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
        "Mark Boulton's Five Simple Steps" => 'http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/',
    );
test_textframe( $document, $html, \@data, \%links );


# test that reference links correctly expand out (even if the result would
# then not be able to be parsed correctly - as reference links can be
# anywhere, but generated documents have them at the end)
$document   = <<END;
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
$html        
    = q(<p>This block has a reference link to <a)
    . qq( href='http://www.google.com/'>Google</a>.</p>\n)
    . q(<p>This block has a different link to <a)
    . qq( href='http://www.google.co.uk/'>Google</a>.</p>\n)
    . q(<p>Last block also links to <a)
    . qq( href='http://www.google.com/'>Google</a>. But which?</p>\n);
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            text => [
                {
                    type => 'string',
                    text => 'This block has a reference link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                    uri  => '',
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
            text => [
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
            text => [
                {
                    type => 'string',
                    text => 'Last block also links to ',
                },
                {
                    type => 'link',
                    text => "Google",
                    uri  => '',
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
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test that reference links with shared link text are correctly
# overwritten by intermediate links with the same shared link text
$document   = <<END;
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
$html        
    = q(<p>This block has a reference link to <a)
    . qq( href='http://www.google.co.uk/'>Google</a>. But which?</p>\n)
    . q(<p>This block has a different link to <a)
    . qq( href='http://www.google.co.uk/'>Google</a>.</p>\n);
@data = (
        {
            context => [
                'indent',
                'indent',
                'block',
            ],
            text => [
                {
                    type => 'string',
                    text => 'This block has a reference link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                    uri  => '',
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
            text => [
                {
                    type => 'string',
                    text => 'This block has a different link to ',
                },
                {
                    type => 'link',
                    text => 'Google',
                    uri  => '',
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
test_textframe( $document, $html, \@data, \%links, $ref_doc );
