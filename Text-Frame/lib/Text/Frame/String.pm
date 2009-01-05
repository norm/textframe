package Text::Frame::String;

use strict;
use warnings;

use charnames qw( :full );
use utf8;

use Readonly;
use Text::Autoformat;


Readonly my $EMDASH             => "\N{EM DASH}";
Readonly my $ENDASH             => "\N{EN DASH}";
Readonly my $ELLIPSIS           => "\N{HORIZONTAL ELLIPSIS}";
Readonly my $APOSTROPHE         => "\N{RIGHT SINGLE QUOTATION MARK}";
Readonly my $OPEN_QUOTE         => "\N{LEFT SINGLE QUOTATION MARK}";
Readonly my $CLOSE_QUOTE        => "\N{RIGHT SINGLE QUOTATION MARK}";
Readonly my $OPEN_DOUBLE_QUOTE  => "\N{LEFT DOUBLE QUOTATION MARK}";
Readonly my $CLOSE_DOUBLE_QUOTE => "\N{RIGHT DOUBLE QUOTATION MARK}";
Readonly my $HTML_LESSTHAN      => '&lt;';
Readonly my $HTML_GREATERTHAN   => '&gt;';
Readonly my $HTML_AMPERSAND     => '&amp;';
Readonly my $HTML_DOUBLEQUOTE   => '&quot;';



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_string => \&detect_text_string  );
    
    $frame->add_trigger( as_text_string     => \&as_text             );
    
    $frame->add_trigger( as_html_string     => \&as_html             );
    $frame->add_trigger( html_string_escape => \&convert_punctuation );
    $frame->add_trigger( html_string_escape => \&escape_characters   );
    $frame->add_trigger( html_code_escape   => \&escape_characters   );
}


sub detect_text_string {
    my $self   = shift;
    my $string = shift;
    
    # if nothing else, a string is always a string
    return(
              undef,
              {
                  type => 'string',
                  text => $string,
                  
              },
              undef,
          );
}


sub as_text {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;

    $$block .= $item->{'text'};
}
sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    $self->call_trigger( 
            'html_string_escape', 
            \$text 
        );

    $$block .= $text;
}


sub convert_punctuation {
    my $self = shift;
    my $text = shift;
    
    # convert --- to em-dash
    $$text =~ s{ [-][-][-] }{$EMDASH}gsx;
    
    # convert -- to en-dash when between words without spaces
    $$text =~ s{ ( \S ) [-][-] ( \S ) }{$1$ENDASH$2}gsx;
    
    # convert ... to an ellipsis
    $$text =~ s{ [.][.][.] }{$ELLIPSIS}gsx;
    
    # convert single quotes within words to apostrophes
    $$text =~ s{ (\w) ['] (\w) }{$1$APOSTROPHE$2}gsx;
    
    # TODO - the following regexps will be too naive
    
    # convert matched pairs of single quotes
    $$text =~ s{
        ^
        ( .*? )
        '
        ( .*? )
        '
        ( .*? )
        $
    }{$1${OPEN_QUOTE}$2${CLOSE_QUOTE}$3}gsx;
    
    # convert matched pairs of single quotes
    $$text =~ s{
        ^
        ( .*? )
        "
        ( .*? )
        "
        ( .*? )
        $
    }{$1${OPEN_DOUBLE_QUOTE}$2${CLOSE_DOUBLE_QUOTE}$3}gsx;
}
sub escape_characters {
    my $self = shift;
    my $text = shift;
    
    $$text =~ s{ [&] }{$HTML_AMPERSAND}gsx;
    $$text =~ s{ [<] }{$HTML_LESSTHAN}gsx;
    $$text =~ s{ [>] }{$HTML_GREATERTHAN}gsx;
    $$text =~ s{ ["] }{$HTML_DOUBLEQUOTE}gsx;
}


1;
