package Blockchain::Ethereum::Transaction::EIP1559;

use v5.26;
use strict;
use warnings;

use parent qw(Blockchain::Ethereum::Transaction);

use constant TRANSACTION_PREFIX => pack("H*", '02');

sub tx_format {
    return [qw(chain_id nonce max_fee_per_gas max_priority_fee_per_gas gas_limit to value data access_list v r s)];
}

sub serialize {
    my ($self, $signed) = @_;

    my @params = (
        $self->{chain_id},    #
        $self->{nonce},
        $self->{max_priority_fee_per_gas},
        $self->{max_fee_per_gas},
        $self->{gas_limit},
        $self->{to}          // '',
        $self->{value}       // '0x0',
        $self->{data}        // '',
        $self->{access_list} // [],
    );

    push(@params, $self->{v}, $self->{r}, $self->{s}) if $signed;

    # eip-1559 transactions must be prefixed by 2 that is the
    # transaction type
    return TRANSACTION_PREFIX . $self->rlp->encode(\@params);
}

sub set_v {
    my ($self, $y) = @_;

    # eip-1559 uses y directly as the v point
    # instead of using recovery id as the legacy
    # transactions
    $self->{v} = sprintf("0x%x", $y);
    return $self->{v};
}

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::Transaction::EIP1559 - Ethereum Fee Market transaction abstraction

=head1 SYNOPSIS

Transaction abstraction for Legacy transactions

    my $transaction = Blockchain::Ethereum::Transaction::EIP1559->new(
        nonce                    => '0x0',
        max_fee_per_gas          => '0x9',
        max_priority_fee_per_gas => '0x0',
        gas_limit                => '0x1DE2B9',
        to                       => '0x3535353535353535353535353535353535353535'
        value                    => '0xDE0B6B3A7640000',
        data                     => '0x',
        chain_id                 => '0x539'
    );

    $transaction->sign('4646464646464646464646464646464646464646464646464646464646464646');
    my $raw_transaction = $transaction->serialize(1);
    ```

=head1 METHODS

=head2 sign

Check the parent transaction class for details L<Blockchain::Ethereum::Transaction>

=cut

=head2 tx_format

Determines if all required fields for the transaction type are given.

Expected fields:

    - chain_id
    - nonce
    - max_fee_per_gas
    - max_priority_fee_per_gas
    - gas_limit
    - to
    - value
    - data
    - access_list
    - v
    - r
    - s

=over 4

=back

Returns a array reference containing the avaialble fields for the transaction type

=cut

=head2 serialize

Encodes the given transaction parameters to RLP

=over 4

=item * C<$signed> boolean to idenfity if the transaction is already signed (adds v r s if true) or not

=back

Returns the RLP encoded transaction bytes

=cut

=head2 set_v

Sets the v transaction field using the given y-parity

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

    perldoc Blockchain::Ethereum::Transaction::EIP1559

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
