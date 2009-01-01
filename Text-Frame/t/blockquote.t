use strict;
use warnings;

use utf8;

use Test::More      tests => 20;
require 't/testing.pl';

use Text::Frame;



my $document;
my $html;
my @data;
my %links;
my $ref_doc;


# TODO
# do we need to test the structures of the sub-frames?



# test a quoted paragraph
$document = <<END;
    >   Hello 
    >   world.

END
$ref_doc = <<END;
    >   Hello world.

END
$html = <<END;
<blockquote><p>Hello world.</p> </blockquote>
END
@data = (
        {
            context => [
                'indent',
                'blockquote',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => '',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# # test a quoted paragraph with citation
$document = <<END;
    >   From <Mark Boulton's Five Simple Steps>:
    >   With hanging punctuation the flow of text on the left hand side is
    >   uninterrupted. The bullets, glyphs or numbers sit in the gutter to
    >   highlight the list. This representation of a list is more
    >   sophisticated visually and more legible.

<Mark Boulton's Five Simple Steps |
http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/
>
END
$ref_doc = <<END;
    >   From <Mark Boulton's Five Simple Steps>:
    >   With hanging punctuation the flow of text on the left hand side is
    >   uninterrupted. The bullets, glyphs or numbers sit in the gutter to
    >   highlight the list. This representation of a list is more sophisticated
    >   visually and more legible.

<Mark Boulton's Five Simple Steps |
http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/
>
END
$html = <<END;
<blockquote cite='http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/'><p>With hanging punctuation the flow of text on the left hand side is uninterrupted. The bullets, glyphs or numbers sit in the gutter to highlight the list. This representation of a list is more sophisticated visually and more legible.</p> </blockquote>
END
@data = (
        {
            context => [
                'indent',
                'blockquote',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => '',
                },
            ],
        },
    );
%links = (
        'Mark Boulton\'s Five Simple Steps' => 'http://www.markboulton.co.uk/journal/comments/five_simple_steps_to_better_typography_part_2/'
    );
test_textframe( $document, $html, \@data, \%links );


# # test multiple quoted items
$document = <<END;
    >   This is a paragraph.
    >
    >   This is a second paragraph.
    >
    >   This is a third paragraph.

END
$ref_doc = <<END;
    >   This is a paragraph.
    >   
    >   This is a second paragraph.
    >   
    >   This is a third paragraph.

END
$html = <<END;
<blockquote><p>This is a paragraph.</p> <p>This is a second paragraph.</p> <p>This is a third paragraph.</p> </blockquote>
END
@data = (
        {
            context => [
                'indent',
                'blockquote',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => '',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );

# test different types of quoted items - bullets
$document = <<END;
    >   *   List item
    >
    >   *   List item
    >
    >   Paragraph?
    
END
$ref_doc = <<END;
    >   *   List item
    >   
    >   *   List item
    >   
    >   Paragraph?

END
$html = <<END;
<blockquote><ul> <li><p>List item</p></li> <li><p>List item</p></li> </ul> <p>Paragraph?</p> </blockquote>
END
@data = (
        {
            context => [
                'indent',
                'blockquote',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => '',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );


# test different types of quoted items - numbered items
$document = <<END;
    >   #   List item
    >
    >   2.  List item
    >
    >   Paragraph?
    
END
$ref_doc = <<END;
    >   1.  List item
    >   
    >   2.  List item
    >   
    >   Paragraph?

END
$html = <<END;
<blockquote><ol> <li><p>List item</p></li> <li><p>List item</p></li> </ol> <p>Paragraph?</p> </blockquote>
END
@data = (
        {
            context => [
                'indent',
                'blockquote',
                'block',
            ],
            metadata => {},
            text => [
                {
                    type => 'string',
                    text => '',
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, \%links, $ref_doc );