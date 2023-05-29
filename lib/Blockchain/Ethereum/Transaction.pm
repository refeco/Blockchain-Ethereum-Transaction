package Blockchain::Ethereum::Transaction;

use v5.26;
use strict;
use warnings;

use Carp;
use Crypt::PK::ECC;
use Crypt::Perl::ECDSA::Parse;
use Digest::Keccak qw(keccak_256);
use Digest::SHA;

use Blockchain::Ethereum::RLP;

sub tx_format {
    croak 'tx_format method not implemented';
}

sub serialize {
    croak 'terialize method not implemented';
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
    my $pk = Crypt::Perl::ECDSA::Parse::private($importer->export_key_der('private'));

    my $unsigned_rlp = $self->serialize;

    my $tx_hash = keccak_256($unsigned_rlp);

    # if we use the external method sign_sha256 it encodes
    # the key using Digest::SHA::sha256, to avoid that we
    # call the internal function without it
    # my ($r, $s) = $pk->_sign(Digest::SHA::sha256($tx_hash), 'sha256');
    my ($r, $s) = $pk->_sign($tx_hash, 'sha256');

    $self->{r} = $r->as_hex;
    $self->{s} = $s->as_hex;

    my $curve = $pk->_curve();
    my $G     = $pk->_G();
    my $n     = $curve->{n};
    my $k     = Crypt::Perl::ECDSA::Deterministic::generate_k($n, $pk->{private}, $tx_hash, 'sha256');
    my $Q     = $G->multiply($k);

    my $recovery_id = ($Q->get_y->to_bigint->is_odd() ? 1 : 0) | ($Q->get_x->to_bigint->bcmp($r) != 0 ? 2 : 0);

    if ($s->bcmp($n->copy->bdiv(2) > 0)) {
        $self->{s} = $n->copy->bsub($s)->as_hex;
        $recovery_id ^= 1;
    }

    # EIP-155
    my $v = (hex $self->{chain_id}) * 2 + 35 + $recovery_id;
    $self->{v} = "0x" . sprintf("%x", $v);

    my $signed_rlp = $self->serialize(1);

    # return signed raw transaction
    return unpack "H*", $signed_rlp;
}

=head1 NAME

Blockchain::Ethereum::Transaction - Ethereum transaction abstraction

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
