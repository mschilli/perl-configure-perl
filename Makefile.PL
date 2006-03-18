use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Perl::Configure',
    VERSION_FROM      => 'lib/Perl/Configure.pm', # finds $VERSION
    PREREQ_PM         => {
        YAML          => 0,
        Expect        => 0,
        Data::Dumper  => 0,
        Log::Log4perl => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Perl/Configure.pm', # retrieve abstract from module
       AUTHOR         => 'Mike Schilli <m@perlmeister.com>') : ()),
);
