use strict;
use warnings;

use Test::More      tests => 12;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;



# test that a simple block works
$document = <<END;
        A simple paragraph block.

END
$ref_doc = $document;
$html = <<END;
<p>A simple paragraph block.</p>
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
                    text => 'A simple paragraph block.',
                    type => 'string',
                },
            ],
        } 
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );

$document = <<END;
    A simple paragraph block.

END
$data[0]{'context'} = [
        'indent',
        'block',
    ];
test_textframe( $document, $html, \@data, \%links, $ref_doc );
$document = <<END;
            A simple paragraph block.

END
$data[0]{'context'} = [
        'indent',
        'indent',
        'indent',
        'block',
    ];
test_textframe( $document, $html, \@data, \%links, $ref_doc );
