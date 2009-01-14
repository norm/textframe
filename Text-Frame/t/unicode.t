use strict;
use warnings;

use charnames qw( :full );
use utf8;

use Test::More      tests => 12;
require 't/testing.pl';

use File::Temp;
use IO::All -utf8;
use Readonly;
use Storable        qw( dclone );
use Text::Frame;

Readonly my $LETTER_1  => "\N{LATIN CAPITAL LETTER I WITH MACRON}";
Readonly my $LETTER_2  => "\N{LATIN SMALL LETTER N WITH CARON}";
Readonly my $LETTER_3  => "\N{LATIN SMALL LETTER T WITH STROKE}";
Readonly my $LETTER_4  => "\N{LATIN SMALL LETTER TURNED E}";
Readonly my $LETTER_5  => "\N{LATIN SMALL LETTER R WITH ACUTE}";
Readonly my $LETTER_6  => "\N{LATIN SMALL LETTER N WITH CEDILLA}";
Readonly my $LETTER_7  => "\N{LATIN SMALL LETTER A WITH OGONEK}";
Readonly my $LETTER_8  => "\N{LATIN SMALL LETTER T WITH HOOK}";
Readonly my $LETTER_9  => "\N{LATIN SMALL LETTER I WITH INVERTED BREVE}";
Readonly my $LETTER_10 => "\N{LATIN SMALL LETTER O WITH HORN}";
Readonly my $LETTER_11 => "\N{LATIN SMALL LETTER N WITH TILDE}";
Readonly my $LETTER_12 => "\N{LATIN SMALL LETTER A WITH RING ABOVE}";
Readonly my $LETTER_13 => "\N{LATIN SMALL LETTER L WITH BAR}";
Readonly my $LETTER_14 => "\N{LATIN SMALL LETTER I WITH TILDE}";
Readonly my $LETTER_15 => "\N{LATIN SMALL LETTER S WITH COMMA BELOW}";
Readonly my $LETTER_16 => "\N{LATIN SMALL LETTER A WITH CARON}";
Readonly my $LETTER_17 => "\N{LATIN SMALL LETTER T WITH PALATAL HOOK}";
Readonly my $LETTER_18 => "\N{LATIN SMALL LETTER I WITH DOUBLE GRAVE}";
Readonly my $LETTER_19 => "\N{LATIN SMALL LETTER O WITH OGONEK AND MACRON}";
Readonly my $LETTER_20 => "\N{LATIN SMALL LETTER N WITH LONG RIGHT LEG}";
Readonly my $I18N_ISH_STRING
                => $LETTER_1  . $LETTER_2  . $LETTER_3  . $LETTER_4
                 . $LETTER_5  . $LETTER_6  . $LETTER_7  . $LETTER_8
                 . $LETTER_9  . $LETTER_10 . $LETTER_11 . $LETTER_12
                 . $LETTER_13 . $LETTER_14 . $LETTER_15 . $LETTER_16
                 . $LETTER_17 . $LETTER_18 . $LETTER_19 . $LETTER_20;
Readonly my $I18N_ISH_COMPARISON => "Īňŧǝŕņąƭȋơñåƚĩșǎƫȉǭƞ";


my $document;
my $html;
my @data;
my @html_data;
my %links;
my $frame;
my $temp_file;
my $handle;
my $file_contents;


# test that UTF-8 stays as UTF-8 after parsing
$document = <<END;
        A sentence which is an approximation of proper ${I18N_ISH_STRING}.

END
$html = <<HTML;
<p>A sentence which is an approximation of proper ${I18N_ISH_COMPARISON}.</p>
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
                    text => "A sentence which is an approximation of proper ${I18N_ISH_COMPARISON}.",
                },
            ],
        },
    );
%links = ();
test_textframe( $document, $html, \@data, undef, \%links );


# test UTF-8 reading
$frame = Text::Frame->new( file => 't/data/i18nish' );
ok( $frame->as_text() eq $document );
ok( $frame->as_html() eq $html );


# test UTF-8 writing
$temp_file = tmpnam();
$frame->file_as_text( $temp_file );
$handle = io $temp_file;
$file_contents = $handle->all;
ok( $file_contents eq $document );

$frame->file_as_html( $temp_file );
$handle = io $temp_file;
$file_contents = $handle->all;
ok( $file_contents eq $html );

unlink $temp_file;
