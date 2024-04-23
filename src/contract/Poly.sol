// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "../Constants.sol";
import "../Reduce.sol";
import "./Symmetric.sol";
import "../Sampler.sol";
import {use_hint as use_hint_internal} from "../Rounding.sol";
import "./Ntt.sol";
import "./Invntt.sol";

contract Polynomial {
    Ntt immutable _ntt;
    Invntt immutable _invntt;
    Stream immutable _stream;

    constructor(Ntt __ntt, Invntt __invntt, Stream __stream) {
        _ntt = __ntt;
        _invntt = __invntt;
        _stream = __stream;
    }

    struct Poly {
        int32[N] coeffs;
    }

    struct PolyVecK {
        Polynomial.Poly[K] polys;
    }

    struct PolyVecL {
        Polynomial.Poly[L] polys;
    }

    function clone(Poly memory a) public pure returns (Poly memory b) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                b.coeffs[i] = a.coeffs[i];
            }
            return b;
        }
    }

    function reduce(Poly memory a) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                a.coeffs[i] = reduce32(a.coeffs[i]);
            }
            return a;
        }
    }

    function caddq(Poly memory a) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                a.coeffs[i] = caddq32(a.coeffs[i]);
            }
            return a;
        }
    }

    function add(
        Poly memory a,
        Poly memory b
    ) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < 256; i++) {
                a.coeffs[i] = a.coeffs[i] + b.coeffs[i];
            }
            return a;
        }
    }

    function sub(
        Poly memory a,
        Poly memory b
    ) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < 256; i++) {
                a.coeffs[i] = a.coeffs[i] - b.coeffs[i];
            }
            return a;
        }
    }

    function shiftl(Poly memory a) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; i++) {
                a.coeffs[i] = a.coeffs[i] << D_U32;
            }
            return a;
        }
    }

    function ntt(Poly memory a) public view returns (Poly memory) {
        a.coeffs = _ntt.ntt(a.coeffs);
        return a;
    }

    uint256 constant POLY_UNIFORM_NBLOCKS =
        (768 + STREAM128_BLOCKBYTES - 1) / STREAM128_BLOCKBYTES;

    function uniform(
        Poly memory a,
        uint256 seed,
        uint16 nonce
    ) public view returns (Poly memory) {
        unchecked {
            uint256 buflen = POLY_UNIFORM_NBLOCKS * STREAM128_BLOCKBYTES;

            Stream.State memory state = _stream.init(seed, nonce);
            bytes memory buf;
            (state, buf) = _stream.s128_squeeze_nblocks(
                state,
                POLY_UNIFORM_NBLOCKS
            );

            uint256 ctr;
            uint256 off;

            {
                int32[] memory _coef = new int32[](N);
                for (uint256 i = 0; i < N; i++) {
                    _coef[i] = a.coeffs[i];
                }
                (_coef, ctr) = rej_uniform(_coef, N, buf, buflen);
                for (uint256 i = 0; i < N; i++) {
                    a.coeffs[i] = _coef[i];
                }
            }

            while (ctr < N) {
                off = buflen % 3;
                for (uint256 i = 0; i < off; i++) {
                    buf[i] = buf[buflen - off + i];
                }
                buflen = off + STREAM128_BLOCKBYTES;
                {
                    bytes memory tmpbuf;
                    (state, tmpbuf) = _stream.s128_squeeze_block(state);
                    // buf[off..] = tmpbuf
                    for (uint256 i = 0; i < STREAM128_BLOCKBYTES; i++) {
                        buf[off + i] = tmpbuf[i];
                    }
                }
                {
                    int32[] memory _coef = new int32[](N - ctr);
                    for (uint256 i = 0; i < (N - ctr); i++) {
                        _coef[i] = a.coeffs[i + ctr];
                    }
                    (_coef, ctr) = rej_uniform(_coef, N - ctr, buf, buflen);
                    for (uint256 i = 0; i < (N - ctr); i++) {
                        a.coeffs[i + ctr] = _coef[i];
                    }
                }
            }

            return a;
        }
    }

    function challenge(bytes32 seed) public view returns (Poly memory a) {
        unchecked {
            uint64 signs = 0;

            Stream.State memory state = _stream.empty();
            state = _stream.absorb(state, bytes.concat(seed));

            bytes memory buf;
            (state, buf) = _stream.s256_squeeze_block(state);

            for (uint64 i = 0; i < 8; ++i) {
                signs |= uint64(uint8(buf[i])) << (8 * i);
            }

            uint256 pos = 8;
            uint256 b;

            for (uint256 i = N - TAU; i < N; ++i) {
                while (true) {
                    if (pos >= SHAKE256_RATE) {
                        (state, buf) = _stream.s256_squeeze_block(state);
                        pos = 0;
                    }
                    b = uint256(uint8(buf[pos]));
                    pos += 1;
                    if (b <= i) {
                        break;
                    }
                }

                a.coeffs[i] = a.coeffs[b];
                a.coeffs[b] = 1 - 2 * int32(int64(signs & 1));
                signs >>= 1;
            }
        }
    }

    function mpointwise(
        Poly memory a,
        Poly memory b
    ) public pure returns (Poly memory c) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                c.coeffs[i] = mreduce64(
                    int64(a.coeffs[i]) * int64(b.coeffs[i])
                );
            }
            return c;
        }
    }

    function use_hint(
        Poly memory a,
        Poly memory b
    ) public pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                a.coeffs[i] = use_hint_internal(
                    a.coeffs[i],
                    uint8(uint32(b.coeffs[i]))
                );
            }
            return a;
        }
    }

    function chknorm(Poly memory a, int32 b) public pure returns (bool) {
        unchecked {
            int32 t;
            if (b > (Q_I32 - 1) / 8) {
                return true;
            }

            for (uint256 i = 0; i < N; ++i) {
                int32 ai = a.coeffs[i];
                t = ai >> 31;
                t = ai - (t & (2 * ai));
                if (t >= b) {
                    return true;
                }
            }

            return false;
        }
    }

    function pack_w1(Poly memory a) public pure returns (bytes memory) {
        unchecked {
            // if if GAMMA2 == (Q - 1) / 88
            bytes memory r = new bytes(POLYW1_PACKEDBYTES);
            for (uint256 i = 0; i < N / 4; ++i) {
                r[3 * i + 0] = bytes1(uint8(uint32(a.coeffs[4 * i + 0])));
                r[3 * i + 0] |= bytes1(uint8(uint32(a.coeffs[4 * i + 1] << 6)));

                r[3 * i + 1] = bytes1(uint8(uint32(a.coeffs[4 * i + 1] >> 2)));
                r[3 * i + 1] |= bytes1(uint8(uint32(a.coeffs[4 * i + 2] << 4)));

                r[3 * i + 2] = bytes1(uint8(uint32(a.coeffs[4 * i + 2] >> 4)));
                r[3 * i + 2] |= bytes1(uint8(uint32(a.coeffs[4 * i + 3] << 2)));
            }
            // else {
            //     for i in 0..N / 2 {
            //       r[i] = (a.coeffs[2 * i + 0] | (a.coeffs[2 * i + 1] << 4)) as u8;
            //     }
            //   }
            return r;
        }
    }

    function pack_t1(Poly memory a) public pure returns (bytes memory) {
        unchecked {
            bytes memory r = new bytes(POLYT1_PACKEDBYTES);
            for (uint256 i = 0; i < N / 4; ++i) {
                r[5 * i + 0] = bytes1(uint8(uint32(a.coeffs[4 * i + 0] >> 0)));
                r[5 * i + 1] = bytes1(
                    uint8(
                        uint32(
                            (a.coeffs[4 * i + 0] >> 8) |
                                (a.coeffs[4 * i + 1] << 2)
                        )
                    )
                );
                r[5 * i + 2] = bytes1(
                    uint8(
                        uint32(
                            (a.coeffs[4 * i + 1] >> 6) |
                                (a.coeffs[4 * i + 2] << 4)
                        )
                    )
                );
                r[5 * i + 3] = bytes1(
                    uint8(
                        uint32(
                            (a.coeffs[4 * i + 2] >> 4) |
                                (a.coeffs[4 * i + 3] << 6)
                        )
                    )
                );
                r[5 * i + 4] = bytes1(uint8(uint32(a.coeffs[4 * i + 3] >> 2)));
            }
            return r;
        }
    }

    function unpack_t1(bytes memory a) public pure returns (Poly memory r) {
        unchecked {
            for (uint256 i = 0; i < N / 4; ++i) {
                r.coeffs[4 * i + 0] = int32(
                    uint32(uint8(a[5 * i + 0])) |
                        ((uint32((uint8(a[5 * i + 1]))) << 8) & 0x3FF)
                );
                r.coeffs[4 * i + 1] = int32(
                    (uint32(uint8(a[5 * i + 1])) >> 2) |
                        ((uint32(uint8(a[5 * i + 2])) << 6) & 0x3FF)
                );
                r.coeffs[4 * i + 2] = int32(
                    (uint32(uint8(a[5 * i + 2])) >> 4) |
                        ((uint32(uint8(a[5 * i + 3])) << 4) & 0x3FF)
                );
                r.coeffs[4 * i + 3] = int32(
                    (uint32(uint8(a[5 * i + 3])) >> 6) |
                        ((uint32(uint8(a[5 * i + 4])) << 2) & 0x3FF)
                );
            }
        }
    }

    function unpack_z(bytes memory a) public pure returns (Poly memory r) {
        unchecked {
            // if GAMMA1 == 1 << 17
            for (uint256 i = 0; i < N / 4; ++i) {
                r.coeffs[4 * i + 0] = int32(uint32(uint8(a[9 * i + 0])));
                r.coeffs[4 * i + 0] |= int32(uint32(uint8(a[9 * i + 1]))) << 8;
                r.coeffs[4 * i + 0] |= int32(uint32(uint8(a[9 * i + 2]))) << 16;
                r.coeffs[4 * i + 0] &= 0x3FFFF;

                r.coeffs[4 * i + 1] = int32(uint32(uint8(a[9 * i + 2]) >> 2));
                r.coeffs[4 * i + 1] |= int32(uint32(uint8(a[9 * i + 3]))) << 6;
                r.coeffs[4 * i + 1] |= int32(uint32(uint8(a[9 * i + 4]))) << 14;
                r.coeffs[4 * i + 1] &= 0x3FFFF;

                r.coeffs[4 * i + 2] = int32(uint32(uint8(a[9 * i + 4]) >> 4));
                r.coeffs[4 * i + 2] |= int32(uint32(uint8(a[9 * i + 5]))) << 4;
                r.coeffs[4 * i + 2] |= int32(uint32(uint8(a[9 * i + 6]))) << 12;
                r.coeffs[4 * i + 2] &= 0x3FFFF;

                r.coeffs[4 * i + 3] = int32(uint32(uint8(a[9 * i + 6]) >> 6));
                r.coeffs[4 * i + 3] |= int32(uint32(uint8(a[9 * i + 7]))) << 2;
                r.coeffs[4 * i + 3] |= int32(uint32(uint8(a[9 * i + 8]))) << 10;
                r.coeffs[4 * i + 3] &= 0x3FFFF;

                r.coeffs[4 * i + 0] = GAMMA1_I32 - r.coeffs[4 * i + 0];
                r.coeffs[4 * i + 1] = GAMMA1_I32 - r.coeffs[4 * i + 1];
                r.coeffs[4 * i + 2] = GAMMA1_I32 - r.coeffs[4 * i + 2];
                r.coeffs[4 * i + 3] = GAMMA1_I32 - r.coeffs[4 * i + 3];
            }
        }
    }

    function clone_k(
        PolyVecK memory a
    ) public pure returns (PolyVecK memory b) {
        for (uint256 i = 0; i < K; ++i) {
            for (uint256 j = 0; j < N; ++j) {
                b.polys[i].coeffs[j] = a.polys[i].coeffs[j];
            }
        }
    }

    function clone_l(
        PolyVecL memory a
    ) public pure returns (PolyVecL memory b) {
        for (uint256 i = 0; i < K; ++i) {
            for (uint256 j = 0; j < N; ++j) {
                b.polys[i].coeffs[j] = a.polys[i].coeffs[j];
            }
        }
    }

    function ntt_l(PolyVecL memory a) public view returns (PolyVecL memory) {
        // 0..L
        int32[N][4] memory _b = _ntt.ntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ]
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function ntt_k(PolyVecK memory a) public view returns (PolyVecK memory) {
        // 0..L
        int32[N][4] memory _b = _ntt.ntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ]
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function invntt_k(PolyVecK memory a) public view returns (PolyVecK memory) {
        // 0..K
        int32[N][4] memory _b = _invntt.invntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ]
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function matrix_expand(
        uint256 rho
    ) public view returns (PolyVecL[K] memory m) {
        m[0].polys[0] = uniform(m[0].polys[0], rho, uint16((0 << 8) + 0));
        m[0].polys[1] = uniform(m[0].polys[1], rho, uint16((0 << 8) + 1));
        m[0].polys[2] = uniform(m[0].polys[2], rho, uint16((0 << 8) + 2));
        m[0].polys[3] = uniform(m[0].polys[3], rho, uint16((0 << 8) + 3));

        m[1].polys[0] = uniform(m[1].polys[0], rho, uint16((1 << 8) + 0));
        m[1].polys[1] = uniform(m[1].polys[1], rho, uint16((1 << 8) + 1));
        m[1].polys[2] = uniform(m[1].polys[2], rho, uint16((1 << 8) + 2));
        m[1].polys[3] = uniform(m[1].polys[3], rho, uint16((1 << 8) + 3));

        m[2].polys[0] = uniform(m[2].polys[0], rho, uint16((2 << 8) + 0));
        m[2].polys[1] = uniform(m[2].polys[1], rho, uint16((2 << 8) + 1));
        m[2].polys[2] = uniform(m[2].polys[2], rho, uint16((2 << 8) + 2));
        m[2].polys[3] = uniform(m[2].polys[3], rho, uint16((2 << 8) + 3));

        m[3].polys[0] = uniform(m[3].polys[0], rho, uint16((3 << 8) + 0));
        m[3].polys[1] = uniform(m[3].polys[1], rho, uint16((3 << 8) + 1));
        m[3].polys[2] = uniform(m[3].polys[2], rho, uint16((3 << 8) + 2));
        m[3].polys[3] = uniform(m[3].polys[3], rho, uint16((3 << 8) + 3));
    }

    function mpointwise_acc(
        PolyVecL memory u,
        PolyVecL memory v
    ) public pure returns (Polynomial.Poly memory w) {
        // 0
        w = mpointwise(u.polys[0], v.polys[0]);
        // 1..L
        w = add(w, mpointwise(u.polys[1], v.polys[1]));
        w = add(w, mpointwise(u.polys[2], v.polys[2]));
        w = add(w, mpointwise(u.polys[3], v.polys[3]));
        return w;
    }

    function matrix_mpointwise(
        PolyVecL[K] memory mat,
        PolyVecL memory v
    ) public pure returns (PolyVecK memory t) {
        // 0..K
        t.polys[0] = mpointwise_acc(mat[0], v);
        t.polys[1] = mpointwise_acc(mat[1], v);
        t.polys[2] = mpointwise_acc(mat[2], v);
        t.polys[3] = mpointwise_acc(mat[3], v);
        return t;
    }

    function poly_mpointwise(
        Polynomial.Poly memory a,
        PolyVecK memory v
    ) public pure returns (PolyVecK memory r) {
        // 0..K
        r.polys[0] = mpointwise(a, v.polys[0]);
        r.polys[1] = mpointwise(a, v.polys[1]);
        r.polys[2] = mpointwise(a, v.polys[2]);
        r.polys[3] = mpointwise(a, v.polys[3]);
        return r;
    }

    function shiftl(PolyVecK memory a) public pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = shiftl(a.polys[0]);
        a.polys[1] = shiftl(a.polys[1]);
        a.polys[2] = shiftl(a.polys[2]);
        a.polys[3] = shiftl(a.polys[3]);
        return a;
    }

    function sub(
        PolyVecK memory a,
        PolyVecK memory b
    ) public pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = sub(a.polys[0], b.polys[0]);
        a.polys[1] = sub(a.polys[1], b.polys[1]);
        a.polys[2] = sub(a.polys[2], b.polys[2]);
        a.polys[3] = sub(a.polys[3], b.polys[3]);
        return a;
    }

    function reduce(PolyVecK memory a) public pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = reduce(a.polys[0]);
        a.polys[1] = reduce(a.polys[1]);
        a.polys[2] = reduce(a.polys[2]);
        a.polys[3] = reduce(a.polys[3]);
        return a;
    }

    function caddq(PolyVecK memory a) public pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = caddq(a.polys[0]);
        a.polys[1] = caddq(a.polys[1]);
        a.polys[2] = caddq(a.polys[2]);
        a.polys[3] = caddq(a.polys[3]);
        return a;
    }

    function use_hint(
        PolyVecK memory a,
        PolyVecK memory b
    ) public pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = use_hint(a.polys[0], b.polys[0]);
        a.polys[1] = use_hint(a.polys[1], b.polys[1]);
        a.polys[2] = use_hint(a.polys[2], b.polys[2]);
        a.polys[3] = use_hint(a.polys[3], b.polys[3]);
        return a;
    }

    function pack_w1(PolyVecK memory a) public pure returns (bytes memory) {
        bytes memory r = new bytes(K * POLYW1_PACKEDBYTES);
        for (uint256 i = 0; i < K; ++i) {
            bytes memory buf = pack_w1(a.polys[i]);
            for (uint256 j = 0; j < POLYW1_PACKEDBYTES; ++j) {
                r[i * POLYW1_PACKEDBYTES + j] = buf[j];
            }
        }

        return r;
    }

    function chknorm(
        PolyVecL memory v,
        int32 bound
    ) public pure returns (bool) {
        for (uint256 i = 0; i < L; ++i) {
            if (chknorm(v.polys[i], bound)) {
                return true;
            }
        }

        return false;
    }

    function tranform(
        bytes32 c,
        PolyVecL memory z,
        PolyVecK memory h,
        PolyVecL[K] memory mat,
        PolyVecK memory t1
    ) public view returns (bytes memory) {
        Poly memory cp = challenge(c);
        z = ntt_l(z);
        PolyVecK memory w1 = matrix_mpointwise(mat, z);
        cp = ntt(cp);
        t1 = poly_mpointwise(cp, t1);
        w1 = sub(w1, t1);
        w1 = reduce(w1);
        w1 = invntt_k(w1);
        w1 = caddq(w1);
        w1 = use_hint(w1, h);
        return pack_w1(w1);
    }
}
