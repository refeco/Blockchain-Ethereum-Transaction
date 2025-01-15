# NAME

Blockchain::Ethereum::Transaction - Ethereum transaction abstraction

# VERSION

version 0.011

# SYNOPSIS

Ethereum transaction abstraction for signing and generating raw transactions

```perl
# parameters can be hexadecimal strings or Math::BigInt instances
my $transaction = Blockchain::Ethereum::Transaction::EIP1559->new(
    nonce                    => '0x0',
    max_fee_per_gas          => '0x9',
    max_priority_fee_per_gas => '0x0',
    gas_limit                => '0x1DE2B9',
    to                       => '0x3535353535353535353535353535353535353535'
    value                    => Math::BigInt->new('1000000000000000000'),
    data                     => '0x',
    chain_id                 => '0x539'
);

# github.com/refeco/perl-ethereum-keystore
my $key = Blockchain::Ethereum::Keystore::Key->new(
    private_key => pack "H*",
    '4646464646464646464646464646464646464646464646464646464646464646'
);

$key->sign_transaction($transaction);

my $raw_transaction = $transaction->serialize;

print unpack("H*", $raw_transaction);
```

Standalone version:

```
ethereum-raw-tx --tx-type=legacy --chain-id=0x1 --nonce=0x9 --gas-price=0x4A817C800 --gas-limit=0x5208 --to=0x3535353535353535353535353535353535353535 --value=0xDE0B6B3A7640000 --pk=0x4646464646464646464646464646464646464646464646464646464646464646
```

Supported transaction types:

- **Legacy**
- **EIP1559 Fee Market**

# METHODS

## serialize

To be implemented by the child classes, encodes the given transaction parameters to RLP

Returns the RLP encoded transaction bytes

## generate\_v

Generate the transaction v field using the given y-parity

- `$y_parity` y-parity

Returns the v hexadecimal value also sets the v fields from transaction

## hash

SHA3 Hash the serialized transaction object

Returns the SHA3 transaction hash bytes

# AUTHOR

Reginaldo Costa <refeco@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by REFECO.

This is free software, licensed under:

```
The MIT (X11) License
```
