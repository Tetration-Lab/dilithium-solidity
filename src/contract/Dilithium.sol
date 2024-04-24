// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "../Constants.sol";
import "../Reduce.sol";
import "../Sampler.sol";
import {use_hint as use_hint_internal} from "../Rounding.sol";

contract Dilithium {
    struct State {
        bytes32 state;
    }

    struct Poly {
        int32[N] coeffs;
    }

    struct PolyVecK {
        Poly[K] polys;
    }

    struct PolyVecL {
        Poly[L] polys;
    }

    struct PublicKey {
        uint256 rho;
        PolyVecK t1;
    }

    struct ExpandedPublicKey {
        bytes32 packed;
        PolyVecL[K] mat;
        PolyVecK t1;
    }

    struct Signature {
        bytes32 c;
        PolyVecL z;
        PolyVecK h;
    }

    function __zetas() internal pure returns (int64[N] memory) {
        return [
            int64(0),
            25847,
            -2608894,
            -518909,
            237124,
            -777960,
            -876248,
            466468,
            1826347,
            2353451,
            -359251,
            -2091905,
            3119733,
            -2884855,
            3111497,
            2680103,
            2725464,
            1024112,
            -1079900,
            3585928,
            -549488,
            -1119584,
            2619752,
            -2108549,
            -2118186,
            -3859737,
            -1399561,
            -3277672,
            1757237,
            -19422,
            4010497,
            280005,
            2706023,
            95776,
            3077325,
            3530437,
            -1661693,
            -3592148,
            -2537516,
            3915439,
            -3861115,
            -3043716,
            3574422,
            -2867647,
            3539968,
            -300467,
            2348700,
            -539299,
            -1699267,
            -1643818,
            3505694,
            -3821735,
            3507263,
            -2140649,
            -1600420,
            3699596,
            811944,
            531354,
            954230,
            3881043,
            3900724,
            -2556880,
            2071892,
            -2797779,
            -3930395,
            -1528703,
            -3677745,
            -3041255,
            -1452451,
            3475950,
            2176455,
            -1585221,
            -1257611,
            1939314,
            -4083598,
            -1000202,
            -3190144,
            -3157330,
            -3632928,
            126922,
            3412210,
            -983419,
            2147896,
            2715295,
            -2967645,
            -3693493,
            -411027,
            -2477047,
            -671102,
            -1228525,
            -22981,
            -1308169,
            -381987,
            1349076,
            1852771,
            -1430430,
            -3343383,
            264944,
            508951,
            3097992,
            44288,
            -1100098,
            904516,
            3958618,
            -3724342,
            -8578,
            1653064,
            -3249728,
            2389356,
            -210977,
            759969,
            -1316856,
            189548,
            -3553272,
            3159746,
            -1851402,
            -2409325,
            -177440,
            1315589,
            1341330,
            1285669,
            -1584928,
            -812732,
            -1439742,
            -3019102,
            -3881060,
            -3628969,
            3839961,
            2091667,
            3407706,
            2316500,
            3817976,
            -3342478,
            2244091,
            -2446433,
            -3562462,
            266997,
            2434439,
            -1235728,
            3513181,
            -3520352,
            -3759364,
            -1197226,
            -3193378,
            900702,
            1859098,
            909542,
            819034,
            495491,
            -1613174,
            -43260,
            -522500,
            -655327,
            -3122442,
            2031748,
            3207046,
            -3556995,
            -525098,
            -768622,
            -3595838,
            342297,
            286988,
            -2437823,
            4108315,
            3437287,
            -3342277,
            1735879,
            203044,
            2842341,
            2691481,
            -2590150,
            1265009,
            4055324,
            1247620,
            2486353,
            1595974,
            -3767016,
            1250494,
            2635921,
            -3548272,
            -2994039,
            1869119,
            1903435,
            -1050970,
            -1333058,
            1237275,
            -3318210,
            -1430225,
            -451100,
            1312455,
            3306115,
            -1962642,
            -1279661,
            1917081,
            -2546312,
            -1374803,
            1500165,
            777191,
            2235880,
            3406031,
            -542412,
            -2831860,
            -1671176,
            -1846953,
            -2584293,
            -3724270,
            594136,
            -3776993,
            -2013608,
            2432395,
            2454455,
            -164721,
            1957272,
            3369112,
            185531,
            -1207385,
            -3183426,
            162844,
            1616392,
            3014001,
            810149,
            1652634,
            -3694233,
            -1799107,
            -3038916,
            3523897,
            3866901,
            269760,
            2213111,
            -975884,
            1717735,
            472078,
            -426683,
            1723600,
            -1803090,
            1910376,
            -1667432,
            -1104333,
            -260646,
            -3833893,
            -2939036,
            -2235985,
            -420899,
            -2286327,
            183443,
            -976891,
            1612842,
            -3545687,
            -554416,
            3919660,
            -48306,
            -1362209,
            3937738,
            1400424,
            -846154,
            1976782
        ];
    }

    function init(
        uint256 seed,
        uint16 nonce
    ) internal pure returns (State memory) {
        return
            State(
                keccak256(bytes.concat(bytes32(seed), bytes32(uint256(nonce))))
            );
    }

    function absorb(
        State memory st,
        bytes memory input
    ) internal pure returns (State memory) {
        st.state = keccak256(bytes.concat(st.state, input));
        return st;
    }

    function squeeze_bytes(
        State memory st,
        uint256 len
    ) internal pure returns (State memory, bytes memory) {
        unchecked {
            bytes memory buf;
            while (len > 0) {
                if (len < 32) {
                    bytes memory left = new bytes(len);
                    for (uint256 i = 0; i < len; i++) {
                        left[i] = st.state[i];
                    }
                    buf = bytes.concat(buf, left);
                    len = 0;
                } else {
                    buf = bytes.concat(buf, st.state);
                    len -= 32;
                }
                st.state = keccak256(bytes.concat(st.state));
            }
            return (st, buf);
        }
    }

    // n block = n * SHAKE128_RATE bytes
    function s128_squeeze_nblocks(
        State memory st,
        uint256 nblocks
    ) internal pure returns (State memory, bytes memory) {
        return squeeze_bytes(st, SHAKE128_RATE * nblocks);
    }

    // 1 block = SHAKE128_RATE bytes
    function s128_squeeze_block(
        State memory st
    ) internal pure returns (State memory, bytes memory) {
        return squeeze_bytes(st, SHAKE128_RATE);
    }

    // n block = n * SHAKE256_RATE bytes
    function s256_squeeze_nblocks(
        State memory st,
        uint256 nblocks
    ) internal pure returns (State memory, bytes memory) {
        return squeeze_bytes(st, SHAKE256_RATE * nblocks);
    }

    // 1 block = SHAKE256_RATE bytes
    function s256_squeeze_block(
        State memory st
    ) internal pure returns (State memory, bytes memory) {
        return squeeze_bytes(st, SHAKE256_RATE);
    }

    function clone(Poly memory a) internal pure returns (Poly memory b) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                b.coeffs[i] = a.coeffs[i];
            }
            return b;
        }
    }

    function reduce(Poly memory a) internal pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; ++i) {
                a.coeffs[i] = reduce32(a.coeffs[i]);
            }
            return a;
        }
    }

    function caddq(Poly memory a) internal pure returns (Poly memory) {
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
    ) internal pure returns (Poly memory) {
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
    ) internal pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < 256; i++) {
                a.coeffs[i] = a.coeffs[i] - b.coeffs[i];
            }
            return a;
        }
    }

    function shiftl(Poly memory a) internal pure returns (Poly memory) {
        unchecked {
            for (uint256 i = 0; i < N; i++) {
                a.coeffs[i] = a.coeffs[i] << D_U32;
            }
            return a;
        }
    }

    function ntt(
        Poly memory a,
        int64[N] memory zetas
    ) internal pure returns (Poly memory) {
        a.coeffs = ntt(a.coeffs, zetas);
        return a;
    }

    uint256 constant POLY_UNIFORM_NBLOCKS =
        (768 + STREAM128_BLOCKBYTES - 1) / STREAM128_BLOCKBYTES;

    function uniform(
        Poly memory a,
        uint256 seed,
        uint16 nonce
    ) internal pure returns (Poly memory) {
        unchecked {
            uint256 buflen = POLY_UNIFORM_NBLOCKS * STREAM128_BLOCKBYTES;

            State memory state = init(seed, nonce);
            bytes memory buf;
            (state, buf) = s128_squeeze_nblocks(state, POLY_UNIFORM_NBLOCKS);

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
                    (state, tmpbuf) = s128_squeeze_block(state);
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

    function challenge(bytes32 seed) internal pure returns (Poly memory a) {
        unchecked {
            uint64 signs = 0;

            State memory state;
            state = absorb(state, bytes.concat(seed));

            bytes memory buf;
            (state, buf) = s256_squeeze_block(state);

            for (uint64 i = 0; i < 8; ++i) {
                signs |= uint64(uint8(buf[i])) << (8 * i);
            }

            uint256 pos = 8;
            uint256 b;

            for (uint256 i = N - TAU; i < N; ++i) {
                while (true) {
                    if (pos >= SHAKE256_RATE) {
                        (state, buf) = s256_squeeze_block(state);
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
    ) internal pure returns (Poly memory c) {
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
    ) internal pure returns (Poly memory) {
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

    function chknorm(Poly memory a, int32 b) internal pure returns (bool) {
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

    function pack_w1(Poly memory a) internal pure returns (bytes memory) {
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

    function pack_t1(Poly memory a) internal pure returns (bytes memory) {
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

    function unpack_t1(bytes memory a) internal pure returns (Poly memory r) {
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

    function unpack_z(bytes memory a) internal pure returns (Poly memory r) {
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
    ) internal pure returns (PolyVecK memory b) {
        for (uint256 i = 0; i < K; ++i) {
            for (uint256 j = 0; j < N; ++j) {
                b.polys[i].coeffs[j] = a.polys[i].coeffs[j];
            }
        }
    }

    function clone_l(
        PolyVecL memory a
    ) internal pure returns (PolyVecL memory b) {
        for (uint256 i = 0; i < K; ++i) {
            for (uint256 j = 0; j < N; ++j) {
                b.polys[i].coeffs[j] = a.polys[i].coeffs[j];
            }
        }
    }

    function ntt_l(
        PolyVecL memory a,
        int64[N] memory zetas
    ) internal pure returns (PolyVecL memory) {
        // 0..L
        int32[N][4] memory _b = ntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ],
            zetas
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function ntt_k(
        PolyVecK memory a,
        int64[N] memory zetas
    ) internal pure returns (PolyVecK memory) {
        // 0..L
        int32[N][4] memory _b = ntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ],
            zetas
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function invntt_k(
        PolyVecK memory a,
        int64[N] memory zetas
    ) internal pure returns (PolyVecK memory) {
        // 0..K
        int32[N][4] memory _b = invntt_4(
            [
                a.polys[0].coeffs,
                a.polys[1].coeffs,
                a.polys[2].coeffs,
                a.polys[3].coeffs
            ],
            zetas
        );
        a.polys[0].coeffs = _b[0];
        a.polys[1].coeffs = _b[1];
        a.polys[2].coeffs = _b[2];
        a.polys[3].coeffs = _b[3];
        return a;
    }

    function matrix_expand(
        uint256 rho
    ) internal pure returns (PolyVecL[K] memory m) {
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
    ) internal pure returns (Poly memory w) {
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
    ) internal pure returns (PolyVecK memory t) {
        // 0..K
        t.polys[0] = mpointwise_acc(mat[0], v);
        t.polys[1] = mpointwise_acc(mat[1], v);
        t.polys[2] = mpointwise_acc(mat[2], v);
        t.polys[3] = mpointwise_acc(mat[3], v);
        return t;
    }

    function poly_mpointwise(
        Poly memory a,
        PolyVecK memory v
    ) internal pure returns (PolyVecK memory r) {
        // 0..K
        r.polys[0] = mpointwise(a, v.polys[0]);
        r.polys[1] = mpointwise(a, v.polys[1]);
        r.polys[2] = mpointwise(a, v.polys[2]);
        r.polys[3] = mpointwise(a, v.polys[3]);
        return r;
    }

    function shiftl(PolyVecK memory a) internal pure returns (PolyVecK memory) {
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
    ) internal pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = sub(a.polys[0], b.polys[0]);
        a.polys[1] = sub(a.polys[1], b.polys[1]);
        a.polys[2] = sub(a.polys[2], b.polys[2]);
        a.polys[3] = sub(a.polys[3], b.polys[3]);
        return a;
    }

    function reduce(PolyVecK memory a) internal pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = reduce(a.polys[0]);
        a.polys[1] = reduce(a.polys[1]);
        a.polys[2] = reduce(a.polys[2]);
        a.polys[3] = reduce(a.polys[3]);
        return a;
    }

    function caddq(PolyVecK memory a) internal pure returns (PolyVecK memory) {
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
    ) internal pure returns (PolyVecK memory) {
        // 0..K
        a.polys[0] = use_hint(a.polys[0], b.polys[0]);
        a.polys[1] = use_hint(a.polys[1], b.polys[1]);
        a.polys[2] = use_hint(a.polys[2], b.polys[2]);
        a.polys[3] = use_hint(a.polys[3], b.polys[3]);
        return a;
    }

    function pack_w1(PolyVecK memory a) internal pure returns (bytes memory) {
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
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < L; ++i) {
            if (chknorm(v.polys[i], bound)) {
                return true;
            }
        }

        return false;
    }

    function ntt(
        int32[N] memory a,
        int64[N] memory _zetas
    ) internal pure returns (int32[N] memory) {
        unchecked {
            uint256 j;
            uint256 k;
            int32 t;
            int64 zeta;

            for (uint256 len = 128; len > 0; len >>= 1) {
                uint256 start = 0;
                while (start < N) {
                    k += 1;
                    zeta = _zetas[k];
                    j = start;
                    while (j < start + len) {
                        t = mreduce64(zeta * int64(a[j + len]));
                        a[j + len] = a[j] - t;
                        a[j] += t;
                        j += 1;
                    }
                    start = j + len;
                }
            }

            return a;
        }
    }

    function ntt_4(
        int32[N][4] memory a,
        int64[N] memory _zetas
    ) internal pure returns (int32[N][4] memory) {
        unchecked {
            uint256 j;
            uint256 k;
            int32 t;
            int64 zeta;

            for (uint256 len = 128; len > 0; len >>= 1) {
                uint256 start = 0;
                while (start < N) {
                    k += 1;
                    zeta = _zetas[k];
                    j = start;
                    while (j < start + len) {
                        {
                            t = mreduce64(zeta * int64(a[0][j + len]));
                            a[0][j + len] = a[0][j] - t;
                            a[0][j] += t;
                        }
                        {
                            t = mreduce64(zeta * int64(a[1][j + len]));
                            a[1][j + len] = a[1][j] - t;
                            a[1][j] += t;
                        }
                        {
                            t = mreduce64(zeta * int64(a[2][j + len]));
                            a[2][j + len] = a[2][j] - t;
                            a[2][j] += t;
                        }
                        {
                            t = mreduce64(zeta * int64(a[3][j + len]));
                            a[3][j + len] = a[3][j] - t;
                            a[3][j] += t;
                        }
                        j += 1;
                    }
                    start = j + len;
                }
            }

            return a;
        }
    }

    function invntt(
        int32[N] memory a,
        int64[N] memory _zetas
    ) internal pure returns (int32[N] memory) {
        unchecked {
            uint256 j;
            uint256 k = 256;
            int64 zeta;

            for (uint256 len = 1; len < N; len <<= 1) {
                uint256 start = 0;
                while (start < N) {
                    k -= 1;
                    zeta = -_zetas[k];
                    j = start;
                    while (j < start + len) {
                        int32 t = a[j];
                        int32 tl = a[j + len];
                        a[j] = t + tl;
                        a[j + len] = mreduce64(int64(t - tl) * zeta);
                        j += 1;
                    }
                    start = j + len;
                }
            }

            for (uint256 i = 0; i < N; i++) {
                a[i] = mreduce64(F * int64(a[i]));
            }

            return a;
        }
    }

    function invntt_4(
        int32[N][4] memory a,
        int64[N] memory _zetas
    ) internal pure returns (int32[N][4] memory) {
        unchecked {
            uint256 j;
            uint256 k = 256;
            int64 zeta;

            for (uint256 len = 1; len < N; len <<= 1) {
                uint256 start = 0;
                while (start < N) {
                    k -= 1;
                    zeta = -_zetas[k];
                    j = start;
                    while (j < start + len) {
                        {
                            int32 t = a[0][j];
                            int32 tl = a[0][j + len];
                            a[0][j] = t + tl;
                            a[0][j + len] = mreduce64(int64(t - tl) * zeta);
                        }
                        {
                            int32 t = a[1][j];
                            int32 tl = a[1][j + len];
                            a[1][j] = t + tl;
                            a[1][j + len] = mreduce64(int64(t - tl) * zeta);
                        }
                        {
                            int32 t = a[2][j];
                            int32 tl = a[2][j + len];
                            a[2][j] = t + tl;
                            a[2][j + len] = mreduce64(int64(t - tl) * zeta);
                        }
                        {
                            int32 t = a[3][j];
                            int32 tl = a[3][j + len];
                            a[3][j] = t + tl;
                            a[3][j + len] = mreduce64(int64(t - tl) * zeta);
                        }
                        j += 1;
                    }
                    start = j + len;
                }
            }

            for (uint256 i = 0; i < N; i++) {
                a[0][i] = mreduce64(F * int64(a[0][i]));
                a[1][i] = mreduce64(F * int64(a[1][i]));
                a[2][i] = mreduce64(F * int64(a[2][i]));
                a[3][i] = mreduce64(F * int64(a[3][i]));
            }

            return a;
        }
    }

    function tranform(
        bytes32 c,
        PolyVecL memory z,
        PolyVecK memory h,
        PolyVecL[K] memory mat,
        PolyVecK memory t1
    ) internal pure returns (bytes memory) {
        Poly memory cp = challenge(c);
        int64[N] memory zetas = __zetas();
        z = ntt_l(z, zetas);
        PolyVecK memory w1 = matrix_mpointwise(mat, z);
        cp = ntt(cp, zetas);
        t1 = poly_mpointwise(cp, t1);
        w1 = sub(w1, t1);
        w1 = reduce(w1);
        w1 = invntt_k(w1, zetas);
        w1 = caddq(w1);
        w1 = use_hint(w1, h);
        return pack_w1(w1);
    }

    function expand(
        PublicKey memory pk
    ) public pure returns (ExpandedPublicKey memory epk) {
        epk.packed = keccak256(pack(pk));
        epk.t1 = clone_k(pk.t1);
        epk.t1 = shiftl(epk.t1);
        epk.t1 = ntt_k(epk.t1, __zetas());
        epk.mat = matrix_expand(pk.rho);
    }

    function verifyExpanded(
        Signature memory sig,
        ExpandedPublicKey memory pk,
        bytes memory m
    ) public pure returns (bool) {
        bytes32 mul = keccak256(bytes.concat(pk.packed, m));
        bytes32 mur = keccak256(bytes.concat(mul));

        if (chknorm(sig.z, int32(int256(GAMMA1 - BETA)))) {
            return false;
        }

        bytes memory buf = tranform(sig.c, sig.z, sig.h, pk.mat, pk.t1);
        bytes32 c2 = keccak256(bytes.concat(mul, mur, buf));

        return c2 == sig.c;
    }

    function verifyExpandedBytes(
        bytes memory _sig,
        ExpandedPublicKey memory pk,
        bytes memory m
    ) public pure returns (bool) {
        Dilithium.Signature memory sig = unpackSig(_sig);

        bytes32 mul = keccak256(bytes.concat(pk.packed, m));
        bytes32 mur = keccak256(bytes.concat(mul));

        if (chknorm(sig.z, int32(int256(GAMMA1 - BETA)))) {
            return false;
        }

        bytes memory buf = tranform(sig.c, sig.z, sig.h, pk.mat, pk.t1);
        bytes32 c2 = keccak256(bytes.concat(mul, mur, buf));

        return c2 == sig.c;
    }

    function verify(
        Signature memory sig,
        PublicKey memory pk,
        bytes memory m
    ) public pure returns (bool) {
        ExpandedPublicKey memory epk = expand(pk);
        return verifyExpanded(sig, epk, m);
    }

    function pack(PublicKey memory pk) public pure returns (bytes memory) {
        unchecked {
            bytes memory buf;
            buf = bytes.concat(buf, bytes32(pk.rho));
            for (uint256 i = 0; i < K; i++) {
                buf = bytes.concat(buf, pack_t1(pk.t1.polys[i]));
            }
            return buf;
        }
    }

    function unpackPk(
        bytes memory _pk
    ) public pure returns (PublicKey memory pk) {
        unchecked {
            bytes memory _rho = new bytes(32);
            for (uint256 i = 0; i < 32; i++) {
                _rho[i] = _pk[i];
            }
            pk.rho = uint256(bytes32(_rho));
            for (uint256 i = 0; i < K; i++) {
                bytes memory buf = new bytes(POLYT1_PACKEDBYTES);
                for (uint256 j = 0; j < POLYT1_PACKEDBYTES; j++) {
                    buf[j] = _pk[32 + i * POLYT1_PACKEDBYTES + j];
                }
                pk.t1.polys[i] = unpack_t1(buf);
            }
        }
    }

    function unpackSig(
        bytes memory _sig
    ) public pure returns (Signature memory sig) {
        unchecked {
            bytes memory _c = new bytes(32);
            for (uint256 i = 0; i < 32; ++i) {
                _c[i] = _sig[i];
            }
            sig.c = bytes32(_c);

            uint256 index = 32;

            for (uint256 i = 0; i < L; ++i) {
                bytes memory buf = new bytes(POLYZ_PACKEDBYTES);
                for (uint256 j = 0; j < POLYZ_PACKEDBYTES; j++) {
                    buf[j] = _sig[index + j];
                }
                sig.z.polys[i] = unpack_z(buf);
                index += POLYZ_PACKEDBYTES;
            }

            index = 32 + L * POLYZ_PACKEDBYTES;

            uint8 k = 0;
            for (uint256 i = 0; i < K; ++i) {
                uint8 sigidxoi = uint8(_sig[index + OMEGA + i]);

                if (sigidxoi < k || sigidxoi > OMEGA_U8) {
                    revert("invalid signature, omega");
                }

                for (uint256 j = k; j < sigidxoi; ++j) {
                    if (j > k && _sig[index + j] <= _sig[index + j - 1]) {
                        revert("invalid signature, not ordered");
                    }

                    sig.h.polys[i].coeffs[uint8(_sig[index + j])] = 1;
                }

                k = sigidxoi;
            }

            for (uint8 j = k; j < OMEGA_U8; ++j) {
                if (_sig[index + j] > 0) {
                    revert("invalid signature, extra indices not zero");
                }
            }
        }
    }
}
