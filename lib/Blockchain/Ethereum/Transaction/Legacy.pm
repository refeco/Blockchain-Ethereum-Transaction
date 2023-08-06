use v5.26;
use Object::Pad;

class Blockchain::Ethereum::Transaction::Legacy :does(Blockchain::Ethereum::Transaction) {
    field $gas_price :reader :writer :param;

    method serialize {

        my @params = (
            $self->nonce,    #
            $self->gas_price,
            $self->gas_limit,
            $self->to,
            $self->value,
            $self->data,
        );

        if ($self->v && $self->r && $self->s) {
            push(@params, $self->v, $self->r, $self->s);
        } else {
            push(@params, $self->chain_id, '0x', '0x');
        }

        return $self->rlp->encode(\@params);
    }

    method generate_v ($y_parity) {

        my $v = sprintf("0x%x", (hex $self->chain_id) * 2 + 35 + $y_parity);

        $self->set_v($v);
        return $v;
    }

};

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::Transaction::Legacy - Ethereum Legacy transaction abstraction

=head1 SYNOPSIS

Transaction abstraction for Legacy transactions

     my $transaction = Blockchain::Ethereum::Transaction::Legacy->new(
        nonce     => '0x9',
        gas_price => '0x4A817C800',
        gas_limit => '0x5208',
        to        => '0x3535353535353535353535353535353535353535',
        value     => '0xDE0B6B3A7640000',
        chain_id  => '0x1'

    # github.com/refeco/perl-ethereum-keystore
    my $key = Blockchain::Ethereum::Keystore::Key->new(
        private_key => pack "H*",
        '4646464646464646464646464646464646464646464646464646464646464646'
    );

    $key->sign_transaction($transaction);

    my $raw_transaction = $transaction->serialize;
    ```

=over 4

=back

=head1 METHODS

=head2 sign

Check the parent transaction class for details L<Blockchain::Ethereum::Transaction>

=cut

=head2 serialize

Encodes the given transaction parameters to RLP

Usage:

    serialize -> RLP encoded transaction bytes

=over 4

=back

Returns the RLP encoded transaction bytes

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

    perldoc Blockchain::Ethereum::Transaction::Legacy

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
