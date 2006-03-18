####################################################
# Tests for Perl::Configure::Questions
####################################################
use Test::More tests => 4;
BEGIN { use_ok('Perl::Configure::Questions') };

my @q = Perl::Configure::Questions->questions();
isnt(scalar @q, 0, "Questions != 0");

my $bk = Perl::Configure::Questions->by_key();
like($bk->{'compiler-compiler'}->[0], qr/Which compiler compiler/, 'by-keys');
like($bk->{'compiler-compiler'}->[1], qr/byacc/, 'by-keys');
