package Blockchain::Ethereum::Transaction::Legacy;

use v5.26;
use strict;
use warnings;

use Carp;

use parent qw(Blockchain::Ethereum::Transaction);

sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;

    for my $k (qw(chain_id nonce gas_price gas_limit from to value data v r s)) {
        $self->{$k} = delete $params{$k} if exists $params{$k};
    }

    croak "Invalid params for legacy transaction" if keys %params;

    # set the chain_id to mainnet by default if not given
    $self->{chain_id} //= '0x1';

    return $self;
}

sub serialize_unsigned {
    my ($self) = @_;

    my @params = (
        $self->{nonce},        #
        $self->{gas_price},    #
        $self->{gas_limit},    #
        $self->{to},           #
        $self->{value},        #
        $self->{data},         #
        $self->{chain_id},     #
        '0x',                  #
        '0x',
    );

    return $self->rlp->encode(\@params);
}

sub serialize_signed {
    my ($self) = @_;

    my @params = (
        $self->{nonce},        #
        $self->{gas_price},    #
        $self->{gas_limit},    #
        $self->{to},           #
        $self->{value},        #
        $self->{data},         #
        $self->{v},            #
        $self->{r},            #
        $self->{s},
    );

    return $self->rlp->encode(\@params);
}

1;
