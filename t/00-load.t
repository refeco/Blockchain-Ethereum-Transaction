#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Blockchain::Ethereum::Transaction' ) || print "Bail out!\n";
}

diag( "Testing Blockchain::Ethereum::Transaction $Blockchain::Ethereum::Transaction::VERSION, Perl $], $^X" );
