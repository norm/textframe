use FileHandle;

sub test_textframe {
    my $document = shift;
    my $html     = shift;
    my $data     = shift;
    my $links    = shift;
    my $ref_doc  = shift;
    
    my $frame       = Text::Frame->new( string => $document );
    my @check_data  = $frame->get_blocks();
    my %check_links = %{ $frame->get_links() };
    my $as_html     = $frame->as_html();
    my $as_text     = $frame->as_text();
    
    my $test_doc    = defined $ref_doc 
                          ? $ref_doc
                          : $document;
    
    use Data::Dumper;
    my $handle = FileHandle->new( '/tmp/testing', 'w' );
    print {$handle} "${as_text}--\n";
    print {$handle} "${as_html}--\n";
    print {$handle} Dumper \@check_data;
    print {$handle} Dumper \%check_links;
    undef $handle;
                          
    ok( $as_text eq $test_doc );
    ok( $as_html eq $html     );
    is_deeply( \@check_data,  $data  );
    is_deeply( \%check_links, $links );
}

1;
