#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Blockchain::Ethereum::Transaction::EIP1559;
use Blockchain::Ethereum::Transaction::Legacy;

subtest "eip-155 example" => sub {
    # storage contract from remix
    my $compiled_contract =
        '0x608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100a1565b60405180910390f35b610073600480360381019061006e91906100ed565b61007e565b005b60008054905090565b8060008190555050565b6000819050919050565b61009b81610088565b82525050565b60006020820190506100b66000830184610092565b92915050565b600080fd5b6100ca81610088565b81146100d557600080fd5b50565b6000813590506100e7816100c1565b92915050565b600060208284031215610103576101026100bc565b5b6000610111848285016100d8565b9150509291505056fea2646970667358221220322c78243e61b783558509c9cc22cb8493dde6925aa5e89a08cdf6e22f279ef164736f6c63430008120033';

    my $transaction = Blockchain::Ethereum::Transaction::EIP1559->new(
        nonce                    => '0x',
        max_fee_per_gas          => '0x9502f910',
        max_priority_fee_per_gas => '0x9502f900',
        gas_limit                => '0x5208',
        value                    => '0x',
        data                     => $compiled_contract,
        chain_id                 => '0x1'
    );

    my $raw_transaction = $transaction->sign('7f1fefb0b6648fc59bc3540239ee39e920091b84c93d248a8fd47bf999b9123a');
    note explain $raw_transaction;

    # is($raw_transaction,
    #     'f86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008025a028ef61340bd939bc2195fe537567866003e1a15d3c71ff63e1590620aa636276a067cbe9d8997f761aecb703304b3800ccf555c9f3dc64214b297fb1966a3b6d83'
    # );

    my $rlp     = Blockchain::Ethereum::RLP->new();
    my $decoded = $rlp->decode(pack "H*", $raw_transaction);

    print hex $transaction->{chain_id};

    is hex $decoded->[-3], (hex $transaction->{chain_id}) * (2 + 36), 'correct eip155 v value for contract creation transaction';

};

done_testing;
