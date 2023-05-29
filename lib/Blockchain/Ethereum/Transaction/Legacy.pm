package Blockchain::Ethereum::Transaction::Legacy;

use v5.26;
use strict;
use warnings;

use Carp;

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
        $self->{to} // '',
        $self->{value} // '',
        $self->{data} // '',
    );

    if ($signed) {
        push(@params, $self->{v}, $self->{r}, $self->{s});
    } else {
        push(@params, $self->{chain_id}, '0x', '0x');
    }

    return $self->rlp->encode(\@params);
}

1;
