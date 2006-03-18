package Perl::Configure::Questions;
use strict;
use warnings;
use YAML qw(Load);

our @QA = yaml_read();

###########################################
sub yaml_read {
###########################################

    my $text = join '', <DATA>;
    my $data = Load($text);

    return @$data;
}

###########################################
sub by_key {
###########################################

    my @qa     = @QA;
    my %by_key = ();

    while( my($key, $question, $answer) = splice @qa, 0, 3) {
        $by_key{ $key } = [$question, $answer];
    }

    return \%by_key;
}

###########################################
sub questions {
###########################################

    my $i = 1;
    my @questions = map { $i++ % 3 ? $_ : () } @QA;

    return @questions;
}

###########################################
sub patterns {
###########################################

    return map { quotemeta($_) } questions();
}

###########################################
sub tokens {
###########################################

    my $i = 1;
    my @tokens = map { $i++ % 1 ? $_ : () } @QA;

    return @tokens;
}

1;

=head1 NAME

Perl::Configure::Questions - Questions asked by perl's Configure

=head1 SYNOPSIS

  use Perl::Configure::Questions;

  my @questions = Perl::Configure::Questions->questions();
  my @patterns  = Perl::Configure::Questions->patterns();
  my @tokens    = Perl::Configure::Questions->tokens();

  my $by_key    = Perl::Configure::Questions->by_key();

=head1 DESCRIPTION

C<questions()> returns a list of questions asked by perl's Configure.
C<patterns()> just runs a quotemeta() on the strings returned by
@questions. This module is used internally by Perl::Configure.

=head1 AUTHOR

Mike Schilli, m@perlmeister.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Mike Schilli

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut

__DATA__
--- #YAML:1.0
- instructions
- Would you like to see the instructions
- n
---
- config-sh-reuse
- I see a config.sh file
- n
---
- os-defaults
- Which of these apply, if any
- Policy linux
---
- os-name
- Operating system name
- linux
---
- os-version
- Operating system version?
- 2.6.5-1.358smp
---
- socks
- Build Perl for SOCKS?
- n
---
- io
- Use the PerlIO abstraction layer?
- y
---
- threads
- Build a threading Perl?
- n
---
- multiplicity
- Build Perl for multiplicity?
- n
---
- compiler
- Use which C compiler?
- cc
---
- 'lib-dirs'
- Directories to use for library searches?
- '/usr/local/lib /lib /usr/lib'
---
- lib-extension
- |-
  What is the file extension used for shared libraries?
- so
---
- long-doubles
- Try to use long doubles if available?
- n
---
- libs
- What libraries to use?
- '-lnsl -lgdbm -ldb -ldl -lm -lcrypt -lutil -lc'
---
- optimizer
- What optimizer/debugger flag should be used?
- '-O2'
---
- ccflags
- Any additional cc flags?
- '-fno-strict-aliasing -pipe -I/usr/local/include'
---
- ldflags
- Any additional ld flags (NOT including libraries)?
- '-L/usr/local/lib'
---
- 64-bit-integers
- Try to use 64-bit integers, if available?
- n
---
- 64-bit-support
- Try to use maximal 64-bit support, if available?
- n
---
- arch
- What is your architecture name
- i686-linux
---
- prefix
- Installation prefix to use?
- '/home/username/PERL'
---
- path-install
- What installation prefix should I use for installing files?
- '/home/username/PERL'
---
- path-private
- Pathname where the private library files will reside?
- '/home/username/PERL/lib/perl5/5.8'
---
- path-public-arch
- Where do you want to put the public architecture-dependent libraries?
- '/home/username/PERL/lib/perl5/5.8/i686-linux'
---
- path-public-arch
- Other username to test security of setuid scripts with?
- none
---
- setuid-secure
- Does your kernel have *secure* setuid scripts?
- n
---
- setuid-emu
- 'Do you want to do setuid/setgid emulation?'
- n
---
- malloc-wrap
- Do you wish to wrap malloc calls to protect against potential overflows?
- y
---
- malloc-perl
- Do you wish to attempt to use the malloc that comes with perl5?
- n
---
- path-addon
- Installation prefix to use for add-on modules and utilities?
- '/home/username/PERL'
---
- path-site-specific
- Pathname for the site-specific library files?
- '/home/username/PERL/lib/perl5/site_perl/5.8'
---
- path-site-specific-arch
- Pathname for the site-specific architecture-dependent library files?
- '/home/username/PERL/lib/perl5/site_perl/5.8/i686-linux'
---
- vendor-specific
- Do you want to configure vendor-specific add-on directories?
- n
---
- dirs-additional
- Colon-separated list of additional directories for perl to search?
- none
---
- path-bin
- Pathname where the public executables will reside?
- '/home/username/PERL/bin'
---
- modules-extra
- Install any extra modules (y or n)?
- n
---
- path-perl-html
- Directory for the main Perl5 html pages?
- none
---
- path-module-html
- Directory for the Perl5 module html pages?
- ''
---
- inc-legacy
- List of earlier versions to include in @INC?
- '5.8.5/i686-linux 5.8.5'
---
- usrbinperl
- 'Do you want to install perl as /usr/bin/perl'
- n
---
- lib-extract-with-nm
- Shall I use /usr/bin/nm to extract C symbols from the libraries?
- n
---
- load-dynamic
- Do you wish to use dynamic loading?
- y
---
- load-dynamic-file
- Source file to use for dynamic loading
- ext/DynaLoader/dl_dlopen.xs
---
- compiler-flags-special
- Any special flags to pass to cc -c to compile shared library modules?
- '-fpic'
---
- lib-dynamic-create-cmd
- What command should be used to create dynamic libraries?
- cc
---
- lib-dynamic-create-flags
- Any special flags to pass to cc to create a dynamically loaded library?
- '-shared -L/usr/local/lib'
---
- lib-dynamic-flags
- Any special flags to pass to cc to use dynamic linking?
- '-Wl,-E'
---
- libperl
- Build a shared libperl.so
- n
---
- path-man-src
- Where do the main Perl5 manual pages (source) go?
- '/home/username/PERL/man/man1'
---
- man-suffix
- What suffix should be used for the main Perl5 man pages?
- 1
---
- path-man-lib-src
- Where do the perl5 library man pages (source) go?
- '/home/username/PERL/man/man3'
---
- man-lib-suffix
- What suffix should be used for the perl5 library man pages?
- 3
---
- host-file-yp
- Are you getting the hosts file via yellow pages?
- n
---
- host-name-confirm
- Your host name appears to be
- y
---
- domain-name
- What is your domain name?
- '.(none)'
---
- email
- What is your e-mail address?
- username@mybox.(none)
---
- email-admin
- Perl administrator e-mail address
- username@mybox.(none)
---
- version-specific-only
- Do you want to install only the version-specific parts of perl?
- n
---
- path-shebang
- What shall I put after the #! to start up perl
- '/home/username/PERL/bin/perl'
---
- path-public-exe
- 'Where do you keep publicly executable scripts?'
- '/home/username/PERL/bin'
---
- path-addon-public-exe
- Pathname where the add-on public executables should be installed?
- '/home/username/PERL/bin'
---
- path-html-site
- Pathname where the site-specific html pages should be installed
- none
---
- path-html-lib-site
- Pathname where the site-specific library html pages should be installed
- none
---
- path-man-site
- Pathname where the site-specific manual pages should be installed
- '/home/username/bin/PERL/man/man1'
---
- path-man-lib-site
- Pathname where the site-specific library manual pages should be installed?
- '/home/username/bin/PERL/man/man3'
---
- path-addon-public-scripts
- Pathname where add-on public executable scripts should be installed?
- '/home/username/PERL/bin'
---
- fast-stdio
- Use the "fast stdio" if available?
- y
---
- files-large
- Try to understand large files, if available?
- y
---
- mod-dyn-ext
- What is the extension of dynamically loaded modules
- so
---
- gethostname-ignore
- Shall I ignore gethostname() from now on?
- n
---
- char-size
- What is the size of a character (in bytes)?
- 1
---
- vfork
- Do you still want to use vfork()
- n
---
- double-align
- Doubles must be aligned on a how-many-byte boundary?
- 4
---
- random-func
- Use which function to generate random numbers?
- drand48
---
- getgroup-pointer
- What type pointer is the second argument to getgroups() and setgroups()?
- gid_t
---
- pager
- What pager is used on your system?
- '/usr/bin/less'
---
- compiler-compiler
- Which compiler compiler (byacc or yacc or bison -y) shall I use?
- '/usr/bin/byacc'
---
- dynamic-extensions
- What extensions do you wish to load dynamically?
- ! >-
  attrs B ByteLoader Cwd Data/Dumper DB_File Devel/DProf Devel/Peek
  Devel/PPPort Digest/MD5 Encode Fcntl File/Glob Filter/Util/Call GDBM_File
  I18N/Langinfo IO IPC/SysV List/Util MIME/Base64 NDBM_File Opcode
  PerlIO/encoding PerlIO/scalar PerlIO/via POSIX re SDBM_File Socket Storable
  Sys/Hostname Sys/Syslog threads Time/HiRes Unicode/Normalize XS/APItest
  XS/Typemap threads/shared
---
- static-extensions
- What extensions do you wish to load statically?
- none
---
- shell-escape
- Press return or use a shell escape to edit config.sh
- ''
- make-depend
- Run make depend now?
- y
