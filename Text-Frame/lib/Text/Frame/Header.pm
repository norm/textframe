package Text::Frame::Header;

use strict;
use warnings;



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block     => \&detect_text_block );
    $frame->add_trigger( output_as_text_header => \&output_as_text    );
    $frame->add_trigger( output_as_html_header => \&output_as_html    );
    $frame->add_trigger( format_output_text    => \&format_header     );
}


sub detect_text_block {
    my $self     = shift;
    my $block    = shift;
    my $previous = shift;
    
    # pass through to block if already detected
    return if 'header' eq $previous;
    
    my $line_count               = ( $block =~ tr{\n}{} );
    my $ends_without_punctuation = ( $block =~ m{ [a-z0-9] $ }ix );
    my $last_line_only_hyphens   = ( $block =~ s{ \n \s* [\-]+ $ }{}sx );
    my $is_header  = 0;
    
    $is_header = 1  if ( $line_count == 0  &&  $ends_without_punctuation );
    $is_header = 1  if ( $line_count  > 0  &&  $last_line_only_hyphens );
    
    return( 
              'header',
              $block,
          ) if ( $is_header );
    return;
}


sub output_as_text {
    my $self    = shift;
    my $details = shift;
    
    $details->{'is_header'} = 1;
}
sub output_as_html {
    my $self    = shift;
    my $details = shift;
    
    my $indent  = $details->{'indent'} || 0;
    my $level   = 1 + $indent;

    push @{ $details->{'start_tags'} }, "<h${level}>";
    push @{ $details->{'end_tags'}   }, "</h${level}>";
}
sub format_header {
    my $self    = shift;
    my $details = shift;
    
    return unless $details->{'is_header'};
    
    my $text                     = $details->{'text'};    
    my $ends_without_punctuation = ( $text =~ m{ [a-z0-9] $ }ix );
    my $longest_line             = 0;
    my $line_count               = 0;
    
    foreach my $line ( split /\n/, $text ) {
        my $length = length $line;
        if ( $length > $longest_line ) {
            $longest_line = $length;
        }
    }
    
    if ( $line_count > 0  ||  !$ends_without_punctuation ) {
        $details->{'text'} .= "\n" . ( q(-) x $longest_line );
    }
}


1;
