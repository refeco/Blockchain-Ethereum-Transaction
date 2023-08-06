requires 'Blockchain::Ethereum::RLP', '0.005';
requires 'Object::Pad', '0.79';
requires 'Digest::Keccak', '0.05';

on 'test' => sub {
  requires 'Blockchain::Ethereum::Keystore::Key', '0.001';
};
