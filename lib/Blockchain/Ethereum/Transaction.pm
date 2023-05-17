package Blockchain::Ethereum::Transaction;

use 5.006;
use strict;
use warnings;

use Carp;
use Crypt::PK::ECC;
use Crypt::Perl::ECDSA::Parse;
use Digest::Keccak qw(keccak_256);
use Digest::SHA;

use Blockchain::Ethereum::RLP::Encoder;

use Data::Dumper;

sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;

    for my $k (qw(chain_id nonce gas_price gas_limit from to value data v r s)) {
        $self->{$k} = delete $params{$k} if exists $params{$k};
    }

    $self->{chain_id} //= '0x1';

    return $self;
}

sub rlp {
    my $self = shift;
    return $self->{rlp} //= Blockchain::Ethereum::RLP::Encoder->new();
}

sub sign {
    my ($self, $private_key) = @_;

    croak "Required parameter private key missing" unless $private_key;

    my $importer = Crypt::PK::ECC->new();
    $importer->import_key_raw(pack('H*', $private_key), 'secp256k1');
    # Crypt::PK::ECC does not provide support for deterministic keys
    my $pk = Crypt::Perl::ECDSA::Parse::private($importer->export_key_der('private'));

    my $unsigned_rlp = $self->serialize_unsigned;

    my $tx_hash = keccak_256($unsigned_rlp);

    # if we use the external method sign_sha256 it encodes
    # the key using Digest::SHA::sha256, to avoid that we
    # call the internal function without it
    my ($r, $s) = $pk->_sign($tx_hash, 'sha256');

    $self->{r} = $r->as_hex;
    $self->{s} = $s->as_hex;

    # EIP-155
    my $v = (hex $self->{chain_id}) * (2 + 35);
    $self->{v} = "0x" . sprintf("%x", $v);

    my $signed_rlp = $self->serialize_signed();

    # return signed raw transaction
    return unpack "H*", $signed_rlp;
}

sub serialize_unsigned {
    my ($self) = @_;

    my @params = (
        $self->{nonce},        #
        $self->{gas_price},    #
        $self->{gas_limit},    #
        $self->{to},           #
        $self->{value},        #
        $self->{data},         #
        $self->{chain_id},     #
        '0x',                  #
        '0x',
    );

    return $self->rlp->encode(\@params);
}

sub serialize_signed {
    my ($self) = @_;

    my @params = (
        $self->{nonce},        #
        $self->{gas_price},    #
        $self->{gas_limit},    #
        $self->{to},           #
        $self->{value},        #
        $self->{data},         #
        $self->{v},            #
        $self->{r},            #
        $self->{s},
    );

    return $self->rlp->encode(\@params);
}

my $transaction = Blockchain::Ethereum::Transaction->new(
    nonce     => '0x9',
    gas_price => '0x4A817C800',
    gas_limit => '0x5208',
    to        => '0x3535353535353535353535353535353535353535',
    value     => '0xDE0B6B3A7640000',
    data      => '0x',
    chain_id  => '0x539'
);

print Dumper $transaction->sign('4646464646464646464646464646464646464646464646464646464646464646');

# my $transaction = Blockchain::Ethereum::Transaction->new(
#     nonce     => '0x1',
#     gas_price => '0x4A817C800',
#     gas_limit => '0x5208',
#     to        => '0x3535353535353535353535353535353535353535',
#     value     => '0xDE0B6B3A7640000',
#     data      => '0x',
#     chain_id  => '0x539'
# );

# $transaction->sign('7906b128ed1bd10e0c8057c29735c9203d4cdfb344a1e9d83e7646cf36860e36');

=head1 NAME

Blockchain::Ethereum::Transaction - The great new Blockchain::Ethereum::Transaction!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Blockchain::Ethereum::Transaction;

    my $foo = Blockchain::Ethereum::Transaction->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-blockchain-ethereum-transaction at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Blockchain-Ethereum-Transaction>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::Transaction


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Blockchain-Ethereum-Transaction>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Blockchain-Ethereum-Transaction>

=item * Search CPAN

L<https://metacpan.org/release/Blockchain-Ethereum-Transaction>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by Reginaldo Costa.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1;    # End of Blockchain::Ethereum::Transaction
