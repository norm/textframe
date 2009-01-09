use Data::Dumper;
use FileHandle;

sub test_textframe {
    my $args = shift;

    # this section can be removed when all legacy tests ported    
    if ( !ref $args ) {
        my $document  = $args;
        my $html      = shift;
        my $text_data = shift;
        my $html_data = shift || $text_data;
        my $links     = shift;
        my $ref_doc   = shift || $document;
        
        $args = {
                input     => $document,
                html      => $html,
                text_data => $text_data,
                html_data => $html_data,
                links     => $links,
                text      => $ref_doc,
            };
    }
    
    # check that the input text is parsed correctly
    # and generates the expected output
    my $input_document  = defined $args->{'text_input'}
                              ? $args->{'text_input'}
                              : $args->{'input'};
    my $output_text     = defined $args->{'text_text'}
                              ? $args->{'text_text'}
                              : $args->{'text'};
    my $output_html     = defined $args->{'text_html'}
                              ? $args->{'text_html'}
                              : $args->{'html'};
    my $output_data     = defined $args->{'text_data'}
                              ? $args->{'text_data'}
                              : $args->{'data'};
    my $output_links    = defined $args->{'text_links'}
                              ? $args->{'text_links'}
                              : $args->{'links'};
    
    my $frame       = Text::Frame->new( string => $input_document );
    my @check_data  = $frame->get_blocks();
    my %check_links = %{ $frame->get_links() };
    my $as_html     = $frame->as_html();
    my $as_text     = $frame->as_text();
    
           ok( $as_text    eq $output_text );
           ok( $as_html    eq $output_html );
    is_deeply( \@check_data,  $output_data  );
    is_deeply( \%check_links, $output_links );
    
    return if defined $args->{'skip_html_tests'};
    
    
    # check that the input html is parsed correctly
    # and generates the expected output
    $input_document  = defined $args->{'html_input'}
                           ? $args->{'html_input'}
                           : $args->{'html'};
    $output_text     = defined $args->{'html_text'}
                           ? $args->{'html_text'}
                           : $args->{'text'};
    $output_html     = defined $args->{'html_html'}
                           ? $args->{'html_html'}
                           : $args->{'html'};
    $output_data     = defined $args->{'html_data'}
                           ? $args->{'html_data'}
                           : $args->{'data'};
    $output_links    = defined $args->{'html_links'}
                           ? $args->{'html_links'}
                           : $args->{'links'};
    
    $frame       = Text::Frame->new( string => $input_document );
    @check_data  = $frame->get_blocks();
    %check_links = %{ $frame->get_links() };
    $as_html     = $frame->as_html();
    $as_text     = $frame->as_text();
    
           ok( $as_text    eq $output_text );
           ok( $as_html    eq $output_html );
    is_deeply( \@check_data,  $output_data  );
    is_deeply( \%check_links, $output_links );
}


sub dump_variable {
    my $variable = shift;
    my $filename = shift || '/tmp/testing';
    
    use FileHandle;
    my $handle = FileHandle->new( $filename, q(w) );
    print {$handle} Dumper $variable;
}

1;
