# perl-ethereum-transaction

Ethereum transaction abstraction for signing and generating raw transactions

# Table of contents

- [Usage](#usage)
- [Supported Transaction Types](#supported-transaction-types)
- [Installation](#installation)
- [Support and Documentation](#support-and-documentation)
- [License and Copyright](#license-and-copyright)

# Usage

```perl
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

    print unpack("H*", $raw_transaction);
```

# Supported Transaction Types

- Legacy
- EIP1559 Fee Market

# Installation

## cpanminus

```
cpanm Blockchain::Ethereum::Transaction
```

## make

```
perl Makefile.PL
make
make test
make install
```

# Support and Documentation

After installing, you can find documentation for this module with the
perldoc command.

```
perldoc Blockchain::Ethereum::Transaction
```

You can also look for information at:

- [Search CPAN](https://metacpan.org/release/Blockchain-Ethereum-Transaction)

# License and Copyright

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  [The MIT License](./LICENSE)
