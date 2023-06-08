package Blockchain::Ethereum::Transaction;

use v5.26;
use strict;
use warnings;

use Carp;
use Crypt::PK::ECC;
use Crypt::Perl::ECDSA::Parse;
use Digest::Keccak qw(keccak_256);

use Blockchain::Ethereum::RLP;
use Blockchain::Ethereum::PrivateKey;

sub tx_format {
    croak 'tx_format method not implemented';
}

sub serialize {
    croak 'terialize method not implemented';
}

sub set_v {
    croak 'set_v method not implemented';
}

sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;

    for my $k ($self->tx_format->@*) {
        $self->{$k} = delete $params{$k} if exists $params{$k};
    }

    croak "Invalid params for transaction type" if keys %params;

    # set the chain_id to mainnet by default if not given
    $self->{chain_id} //= '0x1';

    return $self;
}

sub rlp {
    my $self = shift;
    return $self->{rlp} //= Blockchain::Ethereum::RLP->new();
}

sub sign {
    my ($self, $private_key) = @_;

    croak "Required parameter private key missing" unless $private_key;

    my $importer = Crypt::PK::ECC->new();
    $importer->import_key_raw(pack('H*', $private_key), 'secp256k1');
    # Crypt::PK::ECC does not provide support for deterministic keys
    my $pk = Blockchain::Ethereum::PrivateKey->new(    #
        Crypt::Perl::ECDSA::Parse::private($importer->export_key_der('private')));

    my $unsigned_rlp = $self->serialize;

    my $tx_hash = keccak_256($unsigned_rlp);

    # if we use the external method sign_sha256 it encodes
    # the key using Digest::SHA::sha256, to avoid that we
    # call the internal function without it
    my ($r, $s, $y) = $pk->_sign($tx_hash, 'sha256');

    $self->{r} = $r->as_hex;
    $self->{s} = $s->as_hex;

    $self->set_v($y);

    return $self;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::Transaction - Ethereum transaction abstraction

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

In most cases you don't want to use this directly, use instead:

=over 4

=item * B<Legacy>: L<Blockchain::Ethereum::Transaction::Legacy>

=item * B<EIP1559>: L<Blockchain::Ethereum::Transaction::EIP1559>

=back

=head1 METHODS

=head2 sign

Fill up the r, s and v fields for the transaction

=over 4

=item * C<private_key> - hexadecimal private key (non 0x prefixed)

=back

self

=cut

=head2 tx_format

To be implemented by the child classes, it will determine if all required fields
for the transaction type are given.

=over 4

=back

Returns a array reference containing the avaialble fields for the transaction type

=cut

=head2 serialize

To be implemented by the child classes, encodes the given transaction parameters to RLP

=over 4

=item * C<$signed> boolean to idenfity if the transaction is already signed (adds v r s if true) or not

=back

Returns the RLP encoded transaction bytes

=cut

=head2 set_v

To be implemented by the child classes, set the v transaction field using the given y-parity

=over 4

=item * C<$y> y-parity

=back

Returns the v hexadecimal value also sets the v fields from transaction

=cut

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ethereum-transaction>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::Transaction

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
