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

1;

