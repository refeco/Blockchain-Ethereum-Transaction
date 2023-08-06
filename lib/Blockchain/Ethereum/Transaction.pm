use v5.26;
use Object::Pad ':experimental(init_expr)';

role Blockchain::Ethereum::Transaction {
    use Carp;
    use Digest::Keccak qw(keccak_256);

    use Blockchain::Ethereum::RLP;

    field $chain_id :reader :writer :param;
    field $nonce :reader :writer :param;
    field $gas_limit :reader :writer :param;
    field $to :reader :writer :param    //= '';
    field $value :reader :writer :param //= '0x0';
    field $data :reader :writer :param  //= '';
    field $v :reader :writer :param = undef;
    field $r :reader :writer :param = undef;
    field $s :reader :writer :param = undef;

    field $rlp :reader = Blockchain::Ethereum::RLP->new();

    # required methods
    method serialize;
    method generate_v;

    method hash {

        return keccak_256($self->serialize);
    }
}

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::Transaction - Ethereum transaction abstraction

=head1 VERSION

Version 0.004

=cut

our $VERSION = '0.004';

=head1 SYNOPSIS

In most cases you don't want to use this directly, use instead:

=over 4

=item * B<Legacy>: L<Blockchain::Ethereum::Transaction::Legacy>

=item * B<EIP1559>: L<Blockchain::Ethereum::Transaction::EIP1559>

=back

=head1 METHODS

=head2 serialize

To be implemented by the child classes, encodes the given transaction parameters to RLP

Usage:

    serialize() -> RLP encoded transaction bytes

=over 4

=back

Returns the RLP encoded transaction bytes

=cut

=head2 hash

SHA3 Hash the serialized transaction object

Usage:

    hash() -> SHA3 transaction hash

=over 4

=back

Returns the SHA3 transaction hash bytes

=cut

=head2 generate_v

Generate the transaction v field using the given y-parity

Usage:

    generate_v($y_parity) -> hexadecimal v

=over 4

=item * C<$y_parity> y-parity

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

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
