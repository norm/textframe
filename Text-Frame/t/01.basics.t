use strict;
use warnings;

use Test::More      tests => 3;

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
