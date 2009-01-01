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


# check header indentation is parsed correctly
$document = <<END;
First level header

    Second level header
    
        Third level header
    
            Fourth level header
    
                Fifth level header
    
                    Sixth level header
    
        Not a third level header.
    
END
$ref_doc = <<END;

First level header

    
    Second level header

        
        Third level header

            
            Fourth level header

                
                Fifth level header

                    
                    Sixth level header

        Not a third level header.

END
$html = <<END;
<h1>First level header</h1>
<h2>Second level header</h2>
<h3>Third level header</h3>
<h4>Fourth level header</h4>
<h5>Fifth level header</h5>
<h6>Sixth level header</h6>
<p>Not a third level header.</p>
END
@data = (
        {
            context => [
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'First level header',
                },
            ],
        },
        {
            context => [
                'indent',
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'Second level header',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'Third level header',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'Fourth level header',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'indent',
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'Fifth level header',
                },
            ],
        },
        {
            context => [
                'indent',
                'indent',
                'indent',
                'indent',
                'indent',
                'header',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => 'Sixth level header',
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
            text => [
                {
                    type => 'string',
                    text => 'Not a third level header.',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );
