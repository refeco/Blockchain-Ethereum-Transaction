package Blockchain::Ethereum::Transaction::Legacy;

use v5.26;
use strict;
use warnings;

use parent qw(Blockchain::Ethereum::Transaction);

sub tx_format {
    return [qw(chain_id nonce gas_price gas_limit to value data v r s)];
}

sub serialize {
    my ($self, $signed) = @_;

    my @params = (
        $self->{nonce},    #
        $self->{gas_price},
        $self->{gas_limit},
        $self->{to}    // '',
        $self->{value} // '0x0',
        $self->{data}  // '',
    );

    if ($signed) {
        push(@params, $self->{v}, $self->{r}, $self->{s});
    } else {
        push(@params, $self->{chain_id}, '0x', '0x');
    }

    return $self->rlp->encode(\@params);
}

sub set_v {
    my ($self, $y) = @_;

    my $v = (hex $self->{chain_id}) * 2 + 35 + $y;

    $self->{v} = sprintf("0x%x", $v);
    return $v;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::Transaction::Legacy - Ethereum Legacy transaction abstraction

=head1 SYNOPSIS

Transaction abstraction for Legacy transactions

    my $transaction = Blockchain::Ethereum::Transaction::E->new(
        nonce                    => '0x0',
        max_fee_per_gas          => '0x9',
        max_priority_fee_per_gas => '0x0',
        gas_limit                => '0x1DE2B9',
        value                    => '0x1',
        data                     => '0x0',
        chain_id                 => '0x1'
    );

    $transaction->sign('4646464646464646464646464646464646464646464646464646464646464646');
    my $raw_transaction = $transaction->serialize(1);
    ```

=over 4

=back

=head1 METHODS

=head2 sign

Check the parent transaction class for details L<Blockchain::Ethereum::Transaction>

=cut

=head2 tx_format

Determines if all required fields for the transaction type are given.

Expected fields:

    - chain_id
    - nonce
    - gas_price
    - gas_limit
    - to
    - value
    - data
    - v
    - r
    - s

=over 4

=back

Returns a array reference containing the avaialble fields for the transaction type

=cut

=head2 serialize

Encodes the given transaction parameters to RLP

Usage:

    serialize(1) -> RLP encoded transaction bytes

=over 4

=item * C<$signed> boolean to idenfity if the transaction is already signed (adds v r s if true) or not

=back

Returns the RLP encoded transaction bytes

=cut

=head2 set_v

Sets the v transaction field using the given y-parity

Usage:

    serialize(1) -> RLP encoded transaction bytes

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

    perldoc Blockchain::Ethereum::Transaction::Legacy

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
