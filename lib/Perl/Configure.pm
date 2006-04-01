package Perl::Configure;
use strict;
use warnings;

use Expect;
use Perl::Configure::Questions;
use Data::Dumper;
use YAML qw(Dump LoadFile);
use Log::Log4perl qw(:easy);

our $VERSION = '0.02';

###########################################
sub new {
###########################################
    my($class, @options) = @_;

    my $self = {
        exp       => Expect->new(),
        yml_file  => undef,
        timeout   => 600,
        questions => Perl::Configure::Questions->new(),
        @options
    };

    $self->{bk}        = $self->{questions}->by_key(),
    $self->{bp}        = $self->{questions}->by_pattern(),

    $self->{exp}->raw_pty(1);

    bless $self, $class;
}

###########################################
sub define {
###########################################
    my($self, %args) = @_;

    for my $key (keys %args) {
        if(! exists $self->{bk}->{$key}) {
            LOGDIE "Unknown token: '$key'. Must be one of ", 
                   join(", ", sort $self->{questions}->tokens()), ".";
        }
        $self->{define}->{$key} = $args{$key};
    }
}

###########################################
sub run {
###########################################
    my($self) = @_;

    unlink "Policy.sh";

    my @patterns = $self->{questions}->patterns();

    $self->{exp}->spawn("./Configure")
        or LOGDIE "Cannot spawn: $!\n";

    {   my ($matched_pattern_position, $error, $match,
            $before_match, $after_match) = 
                $self->{exp}->expect(
                             $self->{timeout}, 
                             map { -re => $_ } @patterns);

        if(defined $match) {

            DEBUG "Match: [$match]";

            my $token = $self->{bp}->{
              $patterns[$matched_pattern_position-1]}->[0];

            if(! defined $token) {
                LOGDIE "Internal error: match($match) but no token: ",
                       "pos=$matched_pattern_position ",
                       "error=$error ",
                       "before=$before_match ",
                       "after=$after_match ",
                       ;
            }

            my $response = "";

            if(exists $self->{define}->{$token}) {
                $response = $self->{define}->{$token};
                INFO "Overriding with [$response]";
            } else {
                INFO "Filling in [DEFAULT]";
            }

            DEBUG "Response: [$response]";
            $self->{exp}->send("$response\n");

            redo;
        }
    }
}

1;

__END__

=head1 NAME

Perl::Configure - Answer perl's ./Configure questions reproducibly

=head1 SYNOPSIS

      # Command line:
  $ perl-configure threads=y

      # Perl
  use Perl::Configure;

  my $configurator = Perl::Configure->new();

      # Override certain default settings
  $configurator->define( "threads"     => 'y', 
                         "perlio"      => 'n',
                       );

  $configurator->run();

=head1 DESCRIPTION

Compling perl requires a number of configuration steps.
Running C<./Configure> in a perl source distribution configures it
for compilation on a given platform. It asks about a hundred questions and
then creates a C<config.sh> file, which will later be used
to create a makefile.

However, some answers cause several entries in C<config.sh> to be
modified. For example, if you say you want a threaded perl, C<Configure>
will modify 94 different values in C<config.sh>.

Perl::Configure to the rescue: It runs Configure, recognizes its
questions, fills in preprogrammed answers and gives default answers
otherwise. Perl::Configure is most useful for automatically
reproducing perl builds with slight modifications.

For example, to create a threaded perl with ithreads, use this:

    my $cfg = Perl::Configure->new();
    $cfg->define( "threads"  => 'y', 
                  "ithreads" => 'y',
                );
    $cfg->run();

This will go quickly through all the questions Configure throws at the
user, press 'Enter' on pretty much all of them to accept the defaults,
and will only answer 'y' to the questions 

    Build a threading Perl?

and

    Use the newer interpreter-based ithreads?

which will then cause 94 variables to be set by Configure in
C<config.sh>. Modifying C<config.sh> in this case would be a hopeless
undertaking. While C<./Configure> will (almost) always generate a
C<config.sh> file that can be used later to build perl successfully, a
hand-edited C<config.sh> file is not guaranteed to work.

Note that in most cases you can use C<Configure>'s command line
options to accomplish the same thing:

    ./Configure -Dthreads=y -d

However, this means you have to look at the C<Configure> code
and figure out which setting corresponds to the question.

The mapping between a Perl::Configure token (like C<threads>) and the
corresponding question (like C<Build a threading Perl?>) is defined
in C<Perl::Configure::Questions>. If C<Perl::Configure::Questions>
doesn't define a pattern to recognize a question Configure asks, the
run() method will hang and time out after 60 seconds. B<If you see
this, please send the question to the module maintainer (see below)
to have it added to the existing collection and the next release of
C<Perl::Configure>>.

Here's the list of the mappings defined in this release:

=for TABLE_START

    .---------------------------+-------------------------------.
    | Token                     | Question                      |
    |=--------------------------+------------------------------=|
    | 64-bit-integers           | Try to use 64-bit integers,   |
    |                           | if available?                 |
    | 64-bit-support            | Try to use maximal 64-bit     |
    |                           | support, if available?        |
    | arch                      | What is your architecture     |
    |                           | name                          |
    | carriage-return           | Type carriage return to       |
    |                           | continue                      |
    | ccflags                   | Any additional cc flags?      |
    | char-size                 | What is the size of a         |
    |                           | character (in bytes)?         |
    | compiler                  | Use which C compiler?         |
    | compiler-compiler         | Which compiler compiler       |
    |                           | ANY{(byacc or yacc or bison   |
    |                           | -y)} shall I use?             |
    | compiler-flags-special    | Any special flags to pass to  |
    |                           | ANY{cc -c} to compile shared  |
    |                           | library modules?              |
    | config-sh                 | Shall I use it to set the     |
    |                           | defaults?                     |
    | config-sh-reuse           | I see a config.sh file        |
    | dir-check                 | Use that name anyway?         |
    | dirs-additional           | Colon-separated list of       |
    |                           | additional directories for    |
    |                           | perl to search?               |
    | domain-name               | What is your domain name?     |
    | double-align              | Doubles must be aligned on a  |
    |                           | how-many-byte boundary?       |
    | dynamic-extensions        | What extensions do you wish   |
    |                           | to load dynamically?          |
    | email                     | What is your e-mail address?  |
    | email-admin               | Perl administrator e-mail     |
    |                           | address                       |
    | fast-stdio                | Use the "fast stdio" if       |
    |                           | available?                    |
    | files-large               | Try to understand large       |
    |                           | files, if available?          |
    | getgroup-pointer          | What type pointer is the      |
    |                           | second argument to            |
    |                           | getgroups() and setgroups()?  |
    | gethostname-ignore        | Shall I ignore gethostname()  |
    |                           | from now on?                  |
    | host-file-yp              | Are you getting the hosts     |
    |                           | file via yellow pages?        |
    | host-name-confirm         | Your host name appears to be  |
    | inc-legacy                | List of earlier versions to   |
    |                           | include in @INC?              |
    | instructions              | Would you like to see the     |
    |                           | instructions                  |
    | ithreads                  | Use the newer                 |
    |                           | interpreter-based ithreads?   |
    | keep-reco                 | Keep the recommended value    |
    | ldflags                   | Any additional ld flags (NOT  |
    |                           | including libraries)?         |
    | lib-dirs                  | Directories to use for        |
    |                           | library searches?             |
    | lib-dynamic-create-cmd    | What command should be used   |
    |                           | to create dynamic libraries?  |
    | lib-dynamic-create-flags  | Any special flags to pass to  |
    |                           | ANY{cc} to create a           |
    |                           | dynamically loaded library?   |
    | lib-dynamic-flags         | Any special flags to pass to  |
    |                           | ANY{cc} to use dynamic        |
    |                           | linking?                      |
    | lib-extension             | What is the file extension    |
    |                           | used for shared libraries?    |
    | lib-extract-with-nm       | Shall I use ANY{/usr/bin/nm}  |
    |                           | to extract C symbols from the |
    |                           | libraries?                    |
    | libperl                   | Build a shared libperl.so     |
    | libs                      | What libraries to use?        |
    | load-dynamic              | Do you wish to use dynamic    |
    |                           | loading?                      |
    | load-dynamic-file         | Source file to use for        |
    |                           | dynamic loading               |
    | long-doubles              | Try to use long doubles if    |
    |                           | available?                    |
    | make-depend               | Run make depend now?          |
    | malloc-perl               | Do you wish to attempt to use |
    |                           | the malloc that comes with    |
    | malloc-wrap               | Do you wish to wrap malloc    |
    |                           | calls to protect against      |
    |                           | potential overflows?          |
    | man-lib-suffix            | What suffix should be used    |
    |                           | for the perl5 library man     |
    |                           | pages?                        |
    | man-suffix                | What suffix should be used    |
    |                           | for the main Perl5 man pages? |
    | mod-dyn-ext               | What is the extension of      |
    |                           | dynamically loaded modules    |
    | modules-extra             | Install any extra modules (y  |
    |                           | or n)?                        |
    | multiplicity              | Build Perl for multiplicity?  |
    | optimizer                 | What optimizer/debugger flag  |
    |                           | should be used?               |
    | os-defaults               | Which of these apply, if any  |
    | os-name                   | Operating system name         |
    | os-version                | Operating system version?     |
    | pager                     | What pager is used on your    |
    |                           | system?                       |
    | path-addon                | Installation prefix to use    |
    |                           | for add-on modules and        |
    |                           | utilities?                    |
    | path-addon-public-exe     | Pathname where the add-on     |
    |                           | public executables should be  |
    |                           | installed?                    |
    | path-addon-public-scripts | Pathname where add-on public  |
    |                           | executable scripts should be  |
    |                           | installed?                    |
    | path-bin                  | Pathname where the public     |
    |                           | executables will reside?      |
    | path-html-lib-site        | Pathname where the            |
    |                           | site-specific library html    |
    |                           | pages should be installed     |
    | path-html-site            | Pathname where the            |
    |                           | site-specific html pages      |
    |                           | should be installed           |
    | path-install              | What installation prefix      |
    |                           | should I use for installing   |
    |                           | files?                        |
    | path-man-lib-site         | Pathname where the            |
    |                           | site-specific library manual  |
    |                           | pages should be installed?    |
    | path-man-lib-src          | Where do the perl5 library    |
    |                           | man pages (source) go?        |
    | path-man-site             | Pathname where the            |
    |                           | site-specific manual pages    |
    |                           | should be installed           |
    | path-man-src              | Where do the main Perl5       |
    |                           | manual pages (source) go?     |
    | path-module-html          | Directory for the Perl5       |
    |                           | module html pages?            |
    | path-perl-html            | Directory for the main Perl5  |
    |                           | html pages?                   |
    | path-private              | Pathname where the private    |
    |                           | library files will reside?    |
    | path-public-arch          | Other username to test        |
    |                           | security of setuid scripts    |
    |                           | with?                         |
    | path-public-exe           | Where do you keep publicly    |
    |                           | executable scripts?           |
    | path-shebang              | What shall I put after the #! |
    |                           | to start up perl              |
    | path-site-specific        | Pathname for the              |
    |                           | site-specific library files?  |
    | path-site-specific-arch   | Pathname for the              |
    |                           | site-specific                 |
    |                           | architecture-dependent        |
    |                           | library files?                |
    | path-vendor-specific      | Pathname for the              |
    |                           | vendor-supplied library       |
    |                           | files?                        |
    | path-vendor-specific-arch | Pathname for vendor-supplied  |
    |                           | architecture-dependent files? |
    | path-vendor-specific-bin  | Pathname for the              |
    |                           | vendor-supplied executables   |
    |                           | directory?                    |
    | path-vendor-specific-html | Pathname for the              |
    |                           | vendor-supplied html pages?   |
    | path-vendor-specific-man1 | Pathname for the              |
    |                           | vendor-supplied manual        |
    |                           | section 1 pages?              |
    | path-vendor-specific-man3 | Pathname for the              |
    |                           | vendor-supplied manual        |
    |                           | section 3 pages?              |
    | path-vendor-specific-scri | Pathname for the              |
    | pts                       | vendor-supplied scripts       |
    |                           | directory?                    |
    | perlio                    | Use the PerlIO abstraction    |
    |                           | layer?                        |
    | prefix                    | Installation prefix to use?   |
    | previous-keep             | Keep the previous value       |
    | random-func               | Use which function to         |
    |                           | generate random numbers?      |
    | setuid-emu                | Do you want to do             |
    |                           | setuid/setgid emulation?      |
    | setuid-secure             | Does your kernel have         |
    |                           | *secure* setuid scripts?      |
    | shell-escape              | Press return or use a shell   |
    |                           | escape to edit config.sh      |
    | socks                     | Build Perl for SOCKS?         |
    | static-extensions         | What extensions do you wish   |
    |                           | to load statically?           |
    | threads                   | Build a threading Perl?       |
    | usrbinperl                | Do you want to install perl   |
    |                           | as /usr/bin/perl              |
    | vendor-specific           | Do you want to configure      |
    |                           | vendor-specific add-on        |
    |                           | directories?                  |
    | vendor-specific-prefix    | Installation prefix to use    |
    |                           | for vendor-supplied add-ons   |
    | version-specific-only     | Do you want to install only   |
    |                           | the version-specific parts of |
    |                           | perl?                         |
    | vfork                     | Do you still want to use      |
    |                           | vfork()                       |
    '---------------------------+-------------------------------'


=for TABLE_END

Perl::Configure requires an existing perl installation with a number
of CPAN modules (Expect amongst them), so it can't be used to
bootstrap a machine without a fully functional perl interpreter.

=head1 EXAMPLES

If you want to make sure that a previously generated C<config.sh> file's
content is used as a default and that any discrepancies are kept, use
C<config-sh> and C<previous-keep>.

    my $cfg = Perl::Configure->new();
    $cfg->define( "config-sh"     => 'y', 
                  "previous-keep" => 'y',
                );
    $cfg->run();

If you specify a prefix path that doesn't exist (yet), make sure to
set C<dir-check> to 'y' to answer Configure's question appropriately:

    $cfg->define( "prefix"    => '/quack', 
                  "dir-check" => 'y',
                );

=head1 ADDING QUESTIONS

The questions that C<Perl::Configure> recognizes are stored in 
the __DATA__ section of C<Perl::Configure::Questions> in YAML
format. New releases of C<Perl::Configure> might add to this section
(or change its format, so don't rely on it, use the API instead).

If you encounter a C<Configure> question that C<Perl::Configure> doesn't
recognize (and therefore first hangs and then aborts), the best way to
fix this is submit the question, a proposed token name and a sample
answer to the maintainer of this module (see below). This way, 
C<Perl::Configure> can be improved and other people can benefit from
updates.

If you want a quick fix (or need to fix something very specific to
your platform that no one else will find useful), you can add
questions to C<Perl::Configure::Questions>:

    my $questions = Perl::Configure::Questions->new();

    $questions->add( "path-frobnicate",                 # token
                     "What's your frobnication path?",  # question
                     "/frob" );                         # sample answer

    my $cfg = Perl::Configure->new(questions => $questions);

    $cfg->define( "prefix"          => '/somewhere', 
                  "path-frobnicate" => '/frob',
                );
    $cfg->run();

If you forget to C<add()> the question and the token beforehand, 
C<Perl::Configure>'s C<define> method would complain about an unknown
token and die.

=head1 SEE ALSO

Perl::Configure::Questions

=head1 AUTHOR

Mike Schilli, m@perlmeister.com, 2006

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Mike Schilli

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
