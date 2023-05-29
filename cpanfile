requires 'Digest::Keccak', '=> 0.05';
requires 'Carp', '=> 1.50';
requires 'Crypt::PK::ECC', '=> 0.078';
requires 'Crypt::Perl::ECDSA::Parse', '=> 0.38';

requires 'Blockchain::Ethereum::RLP', '=> 0.001';

on 'test' => sub {
    requires 'Test::More', '=> 0.98';
}
