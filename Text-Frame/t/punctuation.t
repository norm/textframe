use strict;
use warnings;

use charnames qw( :full );
use utf8;

use Test::More      tests => 1;

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


$phrase = <<END;
        Three consecutive periods will be changed ... to an ellipsis.

END
$html = <<END;
<p>Three consecutive periods will be changed ${ELLIPSIS} to an ellipsis.</p>
END
$frame = Text::Frame->new( string => $phrase );
ok( $html eq $frame->as_html() );


# 
# 
#     $phrase = <<END;
# 
#             A double hyphen between words (eg. 1914--1918) is converted to 
#             an en-dash.
# 
# END
#     $correct = <<END;
# 
#             A double hyphen between words (eg. 1914–1918) is converted to 
#             an en-dash.
# 
# END
#     $frame->set_string( $phrase );
#     ok( $correct eq $frame->as_text() );
# 
# 
# 
#     $phrase = <<END;
# 
#             A triple hyphen will be converted to an em-dash --- no matter what
#             surrounds it.
# 
# END
#     $correct = <<END;
# 
#             A triple hyphen will be converted to an em-dash – no matter what
#             surrounds it.
# 
# END
#     $frame->set_string( $phrase );
#     ok( $correct eq $frame->as_text() );
# 
# 
# 
#     $phrase = <<END;
# 
#             Quotation marks are "converted to proper quotation marks".
# 
# END
#     $correct = <<END;
# 
#             Quotation marks are “converted to proper quotation marks”.
# 
# END
#     $frame->set_string( $phrase );
#     ok( $correct eq $frame->as_text() );
# 
# 
# 
#     $phrase = <<END;
# 
#             A single quote inside a word is converted into the proper type
#             of apostrophe - nice isn't it?
# 
# END
#     $correct = <<END;
# 
#             A single quote inside a word is converted into the proper type
#             of apostrophe - nice isn’t it?
# 
# END
#     $frame->set_string( $phrase );
#     ok( $correct eq $frame->as_text() );    
