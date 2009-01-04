package Text::Frame::Header;

use strict;
use warnings;

use utf8;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block    => \&detect_text_block );
    
    $frame->add_trigger( block_as_text_header => \&as_text           );
    $frame->add_trigger( format_block_text    => \&format_header     );
    
    $frame->add_trigger( block_as_html_header => \&as_html           );
}


sub detect_text_block {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    my $gap_hint = shift;
    my $metadata = shift;
    
    # pass through to block if already detected
    return if 'header' eq $previous;
    
    # pass through to block if hinted not to be a header
    return if defined $metadata->{'no_header'};
    
    my $line_count               = ( $block    =~ tr{\n}{} );
    my $ends_without_punctuation = ( $block    =~ m{ [a-z0-9] $ }ix );
    my $last_line_only_hyphens   = ( $block    =~ s{ \n \s* [\-]+ $ }{}sx );
    my $gap_line_count           = ( $gap_hint =~ tr{\n}{} );
    my $atx_style_prefix_suffix  
            = ( $block =~ s{^ ( [=-] ) ( .* ) \1 $}{$2}sx );
    
    my $is_header = 0;
       $is_header = 1  if ( $gap_line_count > 1 );
       $is_header = 1  if ( $line_count == 1  &&  $ends_without_punctuation );
       $is_header = 1  if ( $line_count  > 1  &&  $last_line_only_hyphens );
       $is_header = 1  if ( $atx_style_prefix_suffix );
    
    return( 
              'header',
              $block,
          ) if ( $is_header );
    return;
}


sub as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'is_header'} = 1;
}
sub format_header {
    my $self    = shift;
    my $details = shift;
    
    if ( $details->{'is_header'} ) {
        my $text = $details->{'text'};

        $details->{'text'} = "\n$text";
    }
}


sub as_html {
    my $self    = shift;
    my $details = shift;
    
    my $indent  = $details->{'indent'} || 0;
    my $level   = 1 + $indent;

    $details->{'no_paragraph'} = 1;
    push @{ $details->{'start_tags'} }, "<h${level}>";
    push @{ $details->{'end_tags'}   }, "</h${level}>";
}


1;
