// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "../Constants.sol";
import "./Packing.sol";
import "./Poly.sol";

contract Dilithium {
    Polynomial immutable _poly;
    Packing immutable _packing;

    constructor(Polynomial __poly, Packing __packing) {
        _poly = __poly;
        _packing = __packing;
    }

    struct PublicKey {
        uint256 rho;
        Polynomial.PolyVecK t1;
    }

    struct ExpandedPublicKey {
        bytes32 packed;
        Polynomial.PolyVecL[K] mat;
        Polynomial.PolyVecK t1;
    }

    struct Signature {
        bytes32 c;
        Polynomial.PolyVecL z;
        Polynomial.PolyVecK h;
    }

    function expand(
        PublicKey memory pk
    ) public view returns (ExpandedPublicKey memory epk) {
        epk.packed = keccak256(_packing.pack(pk));
        epk.t1 = _poly.clone_k(pk.t1);
        epk.t1 = _poly.shiftl(epk.t1);
        epk.t1 = _poly.ntt_k(epk.t1);
        epk.mat = _poly.matrix_expand(pk.rho);
    }

    function verifyExpanded(
        Signature memory sig,
        ExpandedPublicKey memory pk,
        bytes memory m
    ) public view returns (bool) {
        bytes32 mul = keccak256(bytes.concat(pk.packed, m));
        bytes32 mur = keccak256(bytes.concat(mul));

        if (_poly.chknorm(sig.z, int32(int256(GAMMA1 - BETA)))) {
            return false;
        }

        bytes memory buf = _poly.tranform(sig.c, sig.z, sig.h, pk.mat, pk.t1);
        bytes32 c2 = keccak256(bytes.concat(mul, mur, buf));

        return c2 == sig.c;
    }

    function verify(
        Signature memory sig,
        PublicKey memory pk,
        bytes memory m
    ) public view returns (bool) {
        ExpandedPublicKey memory epk = expand(pk);
        return verifyExpanded(sig, epk, m);
    }
}
