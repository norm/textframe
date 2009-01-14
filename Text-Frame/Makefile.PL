use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Frame',
    AUTHOR              => 'Mark Norman Francis <norm@cackhanded.net>',
    VERSION_FROM        => 'lib/Text/Frame.pm',
    ABSTRACT_FROM       => 'lib/Text/Frame.pm',
    EXE_FILES           => [ 'bin/textframe' ],
    PL_FILES            => {},
    PREREQ_PM => {
        'Class::Trigger'    => 0,
        'HTML::Parser'      => 0,
        'IO::All'           => 0,
        'Readonly'          => 0,
        'Storable'          => 0,
        'Test::More'        => 0,
        'Text::Autoformat'  => 0,
        'version'           => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Frame-*' },
);
