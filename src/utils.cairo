use starknet::ContractAddress;
use txspaces::constants::{MAX_BLOCK_TIME};
use txspaces::store::{Store, StoreTrait};

const U64: u128 = 0xffffffffffffffff_u128; // 2**64-1

// fn validate_timestamp(player: ContractAddress, timestamp: u64) -> bool {
    
//     if (timestamp - )
// }


fn rotl(x: u128, k: u128) -> u128 {
    assert(k <= 64, 'invalid k');
    // (x << k) | (x >> (64 - k))
    (x * pow2(k)) | rshift(x, 64 - k)
}

// https://xoshiro.di.unimi.it/splitmix64.c
// uint64_t z = (x += 0x9e3779b97f4a7c15);
// z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
// z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
// return z ^ (z >> 31);
fn splitmix(x: u128) -> u128 {
    let z = (x + 0x9e3779b97f4a7c15) & U64;
    let z = ((z ^ rshift(z, 30)) * 0xbf58476d1ce4e5b9) & U64;
    let z = ((z ^ rshift(z, 27)) * 0x94d049bb133111eb) & U64;
    (z ^ rshift(z, 31)) & U64
}

#[inline(always)]
fn rshift(v: u128, b: u128) -> u128 {
    v / pow2(b)
}

fn pow2(mut i: u128) -> u128 {
    let mut p = 1;
    loop {
        if i == 0 {
            break p;
        }
        p *= 2;
        i -= 1;
    }
}