use strict;
use warnings;

use Test::More      tests => 4;
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
%links = (
    );
test_textframe( $document, $html, \@data, \%links );
