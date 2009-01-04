use strict;
use warnings;

use Test::More      tests => 20;
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
$html = <<HTML;
<p>A simple paragraph block.</p>
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
                    text => 'A simple paragraph block.',
                    type => 'string',
                },
            ],
        } 
    );
%links = ();
test_textframe( $document, $html, \@data, \%links );


# test that different indentations are still seen as paragraphs
$document = <<END;
A simple paragraph block.

END
$data[0]{'context'} = [
        'block',
    ];
test_textframe( $document, $html, \@data, \%links, $ref_doc );
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
$document = <<END;
                                A simple paragraph block.

END
$data[0]{'context'} = [
        'indent',
        'indent',
        'indent',
        'indent',
        'indent',
        'indent',
        'indent',
        'indent',
        'block',
    ];
test_textframe( $document, $html, \@data, \%links, $ref_doc );
