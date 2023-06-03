package Blockchain::Ethereum::Transaction::PrivateKey;

use v5.26;
use strict;
use warnings;

use Carp;

use parent qw(Crypt::Perl::ECDSA::PrivateKey);

sub new {
    my ($class, $private_key_ref) = @_;

    my $self = bless $private_key_ref, $class;

    return $self;
}

sub _sign {
    my ($self, $whatsit, $det_hashfuncname) = @_;

    my $dgst = Crypt::Perl::BigInt->from_bytes($whatsit);

    my $priv_num = $self->{'private'};    #Math::BigInt->from_hex( $priv_hex );

    my $n = $self->_curve()->{'n'};       #$curve_data->{'n'};

    my $key_len  = $self->max_sign_bits();
    my $dgst_len = $dgst->bit_length();
    if ($dgst_len > $key_len) {
        croak Crypt::Perl::X::create('TooLongToSign', $key_len, $dgst_len);
    }

    #isa ECPoint
    my $G = $self->_G();
    my ($k, $r, $Q);

    do {
        if ($det_hashfuncname) {
            require Crypt::Perl::ECDSA::Deterministic;
            $k = Crypt::Perl::ECDSA::Deterministic::generate_k($n, $priv_num, $whatsit, $det_hashfuncname,);
        } else {
            $k = Crypt::Perl::Math::randint($n);
        }

        # making it external so I can calculate the y parity
        $Q = $G->multiply($k);    #$Q isa ECPoint

        $r = $Q->get_x()->to_bigint()->copy()->bmod($n);
    } while !$r->is_positive();

    my $s = $k->bmodinv($n);

    #$s *= ( $dgst + ( $priv_num * $r ) );
    $s->bmul($priv_num->copy()->bmuladd($r, $dgst));

    $s->bmod($n);

    # y parity calculation
    # most of the changes unrelated to the parent mode are bellow
    my $y_parity = ($Q->get_y->to_bigint->is_odd() ? 1 : 0) | ($Q->get_x->to_bigint->bcmp($r) != 0 ? 2 : 0);

    my $nb2;
    ($nb2, $_) = $n->copy->bdiv(2);

    if ($s->bcmp($nb2) > 0) {
        $s = $n->copy->bsub($s);
        $y_parity ^= 1;
    }

    return ($r, $s, $y_parity);
}

1;

__END__

=pod

=encoding UTF-8

=head1 SYNOPSIS

This is a child for L<Crypt::Perl::ECDSA::PrivateKey> to overwrite
the function _sign that on the parent module returns only C<$r> and C<$s>,
this version returns the C<$y_parity> as well, what simplifies signing
the transaction.

=head1 METHODS

=head2 _sign

Overwrites L<Crypt::Perl::ECDSA::PrivateKey> adding the recovery_id to the response

=over 4

=item * C<whatsit> - RLP encoded transcation to be signed

=item * C<det_hashfuncname> - deterministic function, in most cases sha_256

=back

L<Crypt::Perl::BigInt> r, L<Crypt::Perl::BigInt> s, uint y_parity

=cut

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-RPL>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::Transaction::PrivateKey

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
