package Perl::Configure;
use strict;
use warnings;

use Expect;
use Perl::Configure::Questions;
use Data::Dumper;
use YAML qw(Dump LoadFile);
use Log::Log4perl qw(:easy);

our $VERSION = '0.01';

###########################################
sub new {
###########################################
    my($class, @options) = @_;

    my $self = {
        exp       => Expect->new(),
        yml_file  => undef,
        timeout   => 60,
        @options
    };

    $self->{questions} = Perl::Configure::Questions->new();
    $self->{bk}        = $self->{questions}->by_key(),
    $self->{bm}        = $self->{questions}->by_match(),

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

    $self->{exp}->spawn("./Configure")
        or LOGDIE "Cannot spawn: $!\n";

    {   my ($matched_pattern_position, $error, $match,
            $before_match, $after_match) = 
                $self->{exp}->expect(
                             $self->{timeout}, 
                             map { -re => $_ } 
                                 $self->{questions}->patterns());

        if(defined $match) {

            DEBUG "Match: [$match]";

            my $token = $self->{bm}->{$match}->[0];

            my $response = "";

            if(exists $self->{define}->{$token}) {
                $response = $self->{define}->{$token};
                INFO "Overriding with [$response}";
            } else {
                INFO "Filling in [DEFAULT]";
            }

            $self->{exp}->send("$response\n");

            redo;
        }
    }
}

1;

__END__

=head1 NAME

Perl::Configure - Answer perl's ./Configure questions reproducably

=head1 SYNOPSIS

  use Perl::Configure;

  my $configurator = Perl::Configure->new();

      # Override certain default settings
  $configurator->define( "threads"     => 'y', 
                         "perlio"      => 'n',
                       );

  $configurator->run();

=head1 DESCRIPTION

Running C<./Configure> in a perl source distribution configures it
for compilation on a given platform. It asks about a hundred questions and
then creates a C<config.sh> file with the settings.

However, some answers cause several entries in C<config.sh> to be
modified. For example, if you say you want a threaded perl, C<Configure>
will modify 94 different values in C<config.sh>.

So, if you want to create a perl with all settings of another perl, just
with threading enabled, there's no easy way to do that. Sure, you can
run Configure, step through all questions one by one. If you botch one,
you'll have to start over. Very annoying.

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
C<config.sh>.

The mapping between a Perl::Configure token (like C<threads>) and the
corresponding question (like C<Build a threading Perl?>) is defined
in C<Perl::Configure::Questions>. If C<Perl::Configure::Questions>
doesn't define a pattern to recognize a question Configure asks, the
run() method will hang and time out after 60 seconds. If you see
this, please send the question to the module maintainer (see below)
to have it added to the existing collection and the next release of
C<Perl::Configure>.

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

=head1 AUTHOR

Mike Schilli, m@perlmeister.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Mike Schilli

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
