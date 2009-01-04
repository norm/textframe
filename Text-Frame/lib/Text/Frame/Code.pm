package Text::Frame::Code;

use strict;
use warnings;

use utf8;

use Readonly;

Readonly my $CATEGORY => 'code';



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block   => \&detect_block_code  );
    $frame->add_trigger( detect_text_string  => \&detect_inline_code );
    
    $frame->add_trigger( start_text_document => \&reset_count        );
    $frame->add_trigger( block_as_text_code  => \&block_as_text      );
    $frame->add_trigger( as_text_code        => \&as_text            );
    
    $frame->add_trigger( start_html_document => \&reset_count        );
    $frame->add_trigger( block_as_html_code  => \&block_as_html      );
    $frame->add_trigger( as_html_code        => \&as_html            );
}


sub detect_inline_code {
    my $self   = shift;
    my $string = shift;
    
    my $find_guillemets_regexp = qr{
            ^
            ( .*? )             # capture everything before the code
            
            [«]                 # code is surrounded by guillemets
            
            (                   # capture the code, which cannot
                \S              # begin or end in white space
                
                (?:             # (this is optional because you can mark just
                    .*?         # one character as being code)
                    \S
                )??
            )
            
            [»]                 # code is surrounded by guillemets
            
            ( .*? )             # capture everything after the code
            
            $
        }x;
    my $find_double_brackets_regexp = qr{
            ^
            ( .*? )             # capture everything before the code

            [<][<]              # code is surrounded by double angle brackets

            (                   # capture the code, which cannot
                \S              # begin or end in white space

                (?:             # (this is optional because you can mark just
                    .*?         # one character as being code)
                    \S
                )??
            )

            [>][>]              # code is surrounded by double angle brackets

            ( .*? )             # capture everything after the code

            $
        }x;
    
    my $shortest       = 0;
    my $shortest_value = 0;
    my @values;
    if ( $string =~ m{$find_guillemets_regexp} ) {
        $shortest       = 1;
        $shortest_value = length $1;
        
        $values[1] = {
            before => $1,
            code   => $2,
            after  => $3,
        };
    }
    if ( $string =~ m{$find_double_brackets_regexp} ) {
        $shortest = 2  if (    0 == $shortest_value  
                            || length $1 < $shortest_value );
        
        $values[2] = {
            before => $1,
            code   => $2,
            after  => $3,
        };
        
    }
    
    if ( $shortest ) {
        my $before = $values[$shortest]->{'before'};
        my $code   = $values[$shortest]->{'code'  };
        my $after  = $values[$shortest]->{'after' };
        
        return(
                $before,
                {
                    type => 'code',
                    text => $code,
                },
                $after,
            );
    }
    
    return;
}
sub detect_block_code {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    
    my $code_block_regexp = qr{
            ^
            (?:
                [«]
                |
                [<][<]
            )

            (?:
                \s+
                ( \w+ )         # capture the optional language
                [:]
            )?
            \s* \n
            
            ( .* )              # capture the code
            
            (?:
                [»]
                |
                [>][>]
            )
        }sx;
    
    if ( $block =~ $code_block_regexp ) {
        my $language = $1;
        my $code     = $2;
        
        # remove the indent
        $code =~ s{^ [ ]{4} }{}gmx;
        
        my $count = $self->get_metadata( $CATEGORY, 'current_block' ) || 1;
        
        $self->set_metadata( $CATEGORY, "code_${count}",     $code        );
        $self->set_metadata( $CATEGORY, "language_${count}", $language    );
        $self->set_metadata( $CATEGORY, 'current_block',     ($count + 1) );
        
        return (
                'code',
                q(),
            );
    }
    return;
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    my $block   = shift;
    
    my $text = $details->{'text'};

    my $contains_guillemets = ( $text =~ m{ [«»] }x );
    
    $$block .= $contains_guillemets 
                   ? "<<${text}>>"
                   : "«${text}»";
}
sub block_as_text {
    my $self    = shift;
    my $details = shift;
    
    my $count     = $self->get_metadata( $CATEGORY, 'current_block'     );
    my $code      = $self->get_metadata( $CATEGORY, "code_${count}"     );
    my $language  = $self->get_metadata( $CATEGORY, "language_${count}" );
    
    my $indent = q( ) x 4;
    my $lang   = defined $language
                     ? " ${language}:" 
                     : q();
       $code  =~ s{^}{$indent}gm;
    my $text   = "«${lang}\n${code}»\n\n";
    
    $details->{'formatted' }  = 1;
    $details->{'first_line'} .= q();
    $details->{'prefix'    } .= q();
    $details->{'right'     } -= 4;
    $details->{'text'      }  = $text;
}


sub as_html {
    my $self  = shift;
    my $item  = shift;
    my $block = shift;
    
    my $text = $item->{'text'};
    $self->call_trigger( 'html_code_escape', \$text );
    
    $$block .= "<code>${text}</code>";
}
sub block_as_html {
    my $self        = shift;
    my $details     = shift;
    my $block_count = shift;
    my $block       = shift;
    my $next        = shift;
    
    my $count     = $self->get_metadata( $CATEGORY, 'current_block'     );
    my $code      = $self->get_metadata( $CATEGORY, "code_${count}"     );
    my $language  = $self->get_metadata( $CATEGORY, "language_${count}" );
    my $lang_attr = defined $language
                        ? " class='${language}'" 
                        : q();
    
    $details->{'text'        } = $code;
    $details->{'formatted'   } = 1;
    $details->{'no_paragraph'} = 1;
    push @{ $details->{'start_tags'} }, "<pre><code${lang_attr}>";
    push @{ $details->{'end_tags'} },   '</code></pre>';
}


sub reset_count {
    my $self = shift;
    
    $self->set_metadata( $CATEGORY, 'current_block', 1 );
}


1;