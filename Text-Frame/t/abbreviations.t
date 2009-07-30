use strict;
use warnings;

use Test::More      tests => 8;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# spot an acronym like W3C
$document = <<END;
        The W3C (World-Wide Web Consortium) are responsible for the
        specification of HTML.

END
$ref_doc = $document;
$html    = <<END;
<p>The <abbr title='World-Wide Web Consortium'>W3C</abbr> are responsible for the specification of HTML.</p>
END
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
                    text => 'The ',
                },
                {
                    type => 'abbreviation',
                    text => 'W3C',
                    title => 'World-Wide Web Consortium',
                    contents => [
                        {
                            type => 'string',
                            text => 'W3C',
                        },
                    ],
                },
                {
                    type => 'string',
                    text => ' are responsible for the specification of HTML.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );
