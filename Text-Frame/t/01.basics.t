use strict;
use warnings;

use Test::More      tests => 5;

use Text::Frame;


# test basic block parsing
my $document = <<END;

        This should be resolved
        as one block.
        
END
my $frame    = Text::Frame->new( string => $document );
my @blocks   = $frame->get_blocks();
ok( 0 == $#blocks );


# ensure spaces after text doesn't cause extra blocks
$document = <<END;
                                        
        This should be resolved         
        as one block.                   
                                        
END
$frame    = Text::Frame->new( string => $document );
@blocks   = $frame->get_blocks();
ok( 0 == $#blocks );



# ensure spaces after text doesn't cause extra blocks
$document = <<END;
                                        
        This should be resolved         
        as two blocks.                  
                                        
        Second block.                   
                                        
END
$frame    = Text::Frame->new( string => $document );
@blocks   = $frame->get_blocks();
ok( 1 == $#blocks );


# ensure we can accept other types of line endings
$document = qq(        This should be resolved\r\n)
          . qq(        as two blocks.\r\n\r\n)
          . qq(        Second block.\r\n\r\n);
$frame    = Text::Frame->new( string => $document );
@blocks   = $frame->get_blocks();
ok( 1 == $#blocks );
$document = qq(        This should be resolved\r)
          . qq(        as two blocks.\r\r)
          . qq(        Second block.\r\r);
$frame    = Text::Frame->new( string => $document );
@blocks   = $frame->get_blocks();
ok( 1 == $#blocks );
