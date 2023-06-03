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

Blockchain::Ethereum::Transaction::Legacy - Ethereum legacy transaction abstraction

=head1 SYNOPSIS

    my $transaction = Blockchain::Ethereum::Transaction::Legacy->new(
        nonce     => '0x9',
        gas_price => '0x4A817C800',
        gas_limit => '0x5208',
        to        => '0x3535353535353535353535353535353535353535',
        value     => '0xDE0B6B3A7640000',
        chain_id  => '0x1'
    );

    $transaction->sign('4646464646464646464646464646464646464646464646464646464646464646');
    my $raw_transaction = $transaction->serialize(1);

    print unpack "H*", $raw_transaction;
    ```

=head1 METHODS

=head2 serialize

RLP encodes the transaction structure

=over 4

=item * C<signed> - specifies if the transaction structure already have v, r, s or not

=back

RLP encoded transaction bytes

=cut

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::Transaction::Legacy

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

