package Text::Frame::Block;

use strict;
use warnings;

use Text::Autoformat;

our @plugin_after = qw( * );



sub initialise {
    my $self  = shift;
    my $frame = shift;
    
    $frame->add_trigger( detect_text_block     => \&detect_text_block );
    $frame->add_trigger( output_as_text_block  => \&output_as_text    );
    $frame->add_trigger( output_as_html_block  => \&output_as_html    );
}


sub detect_text_block {
    my $self  = shift;
    my $block = shift;
    
    # if nothing else, a block is always a block
    return(
              'block',
              $block
          );
}


sub output_as_text {
    my $self    = shift;
    my $details = shift;
    
    my $text  = $details->{'text'};
       $text =~ s{[\s\n]+}{ }gs;
       $text  = autoformat 
                   $text,
                   { 
                       left  => 0, 
                       right => $details->{'right'},
                   };
    
    $text =~ s{ \n\n $ }{}sx;
    
    $details->{'text'} = $text;
}
sub output_as_html {
    my $self    = shift;
    my $details = shift;
    my $count   = shift;
    my $block   = shift;
    my $next    = shift;
    
    # remove unnecessary whitespace
    # TODO - what about preformatted text?
    $details->{'text'}=~ s{[\s\n]+}{ }gs;

    my $previous_element = @{ $block->{'context'} }[$count-1];
    my $need_para        = 1;
    
    $need_para = 0  if 'header' eq $previous_element;
    
    if ( $need_para ) {
        push @{ $details->{'start_tags'} }, '<p>';
        push @{ $details->{'end_tags'}   }, '</p>';
    }
}


1;
