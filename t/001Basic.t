####################################################
# Tests for Perl::Configure::Questions
####################################################
use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('Perl::Configure::Questions') };

my @q = Perl::Configure::Questions->questions();
isnt(scalar @q, 0, "Questions != 0");

my $bk = Perl::Configure::Questions->by_key();
like($bk->{'compiler-compiler'}->[0], qr/Which compiler compiler/, 'by-keys');
like($bk->{'compiler-compiler'}->[1], qr/byacc/, 'by-keys');

my @t = Perl::Configure::Questions->tokens();
isnt(scalar @t, 0, "Tokens != 0");

my @p = Perl::Configure::Questions->patterns();
isnt(scalar @p, 0, "Patterns != 0");
