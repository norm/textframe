use strict;
use warnings;

use utf8;

use Test::More      tests => 4;
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
$html = <<END;
<p>A sentence with some characters likely to interfere with HTML, but which could always be present in source, like 2 &lt; 5, 10 &lt; 5, AT&amp;T, &amp; something which has a spurious &quot; character.</p>
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
                    text => 'A sentence with some characters likely to interfere with HTML, but which could always be present in source, like 2 < 5, 10 > 5, AT&T, & something which has a spurious " character.',
                },
            ],
        },
    );
%links = (
    );
test_textframe( $document, $html, \@data, \%links );

