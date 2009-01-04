use strict;
use warnings;

use charnames qw( :full );
use utf8;

use Test::More      tests => 4;

use Readonly;
use Text::Frame;

Readonly my $EMDASH             => "\N{EM DASH}";
Readonly my $ENDASH             => "\N{EN DASH}";
Readonly my $ELLIPSIS           => "\N{HORIZONTAL ELLIPSIS}";
Readonly my $APOSTROPHE         => "\N{RIGHT SINGLE QUOTATION MARK}";
Readonly my $OPEN_QUOTE         => "\N{LEFT SINGLE QUOTATION MARK}";
Readonly my $CLOSE_QUOTE        => "\N{RIGHT SINGLE QUOTATION MARK}";
Readonly my $OPEN_DOUBLE_QUOTE  => "\N{LEFT DOUBLE QUOTATION MARK}";
Readonly my $CLOSE_DOUBLE_QUOTE => "\N{RIGHT DOUBLE QUOTATION MARK}";



my $frame;
my $phrase;
my $html;


# test ellipses
$phrase = <<END;
        Three consecutive periods («...») will be changed to an ellipsis
        (...).

END
$html = <<HTML;
<p>Three consecutive periods (<code>...</code>) will be changed to an ellipsis (${ELLIPSIS}).</p>
HTML
$frame = Text::Frame->new( string => $phrase );
ok( $html eq $frame->as_html() );


# test en-dashes
$phrase = <<END;
        A double hyphen («--») between words will be changed to an en-dash
        (--), if there are no spaces between the words and the hyphens.

END
$html = <<HTML;
<p>A double hyphen (<code>--</code>) between words will be changed to an en-dash (${ENDASH}), if there are no spaces between the words and the hyphens.</p>
HTML
$frame = Text::Frame->new( string => $phrase );
ok( $html eq $frame->as_html() );


# test em-dashes
$phrase = <<END;
        A triple hyphen («---») will be changed to an em-dash (---).

END
$html = <<HTML;
<p>A triple hyphen (<code>---</code>) will be changed to an em-dash (${EMDASH}).</p>
HTML
$frame = Text::Frame->new( string => $phrase );
ok( $html eq $frame->as_html() );


# test apostrophes
$phrase = <<END;
        Single quote characters within words (such as |isn't|) will be
        converted to apostrophes (isn't).

END
$html = <<HTML;
<p>Single quote characters within words (such as isn't) will be converted to apostrophes (isn${APOSTROPHE}t).</p>
HTML
$frame = Text::Frame->new( string => $phrase );
ok( $html eq $frame->as_html() );


# TODO
# test quotation marks
