// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/Constants.sol";
import "../src/Ntt.sol";

contract Ntt {
    function ntt_internal(
        int32[N] memory a
    ) public pure returns (int32[N] memory) {
        return ntt(a);
    }
}

contract NttTest is Test {
    Ntt NTT;

    function setUp() public {
        NTT = new Ntt();
    }

    function test_ntt() public view {
        int32[N] memory a = [
            int32(-1),
            1,
            -4,
            -3,
            -4,
            4,
            1,
            1,
            2,
            4,
            1,
            2,
            -2,
            3,
            1,
            0,
            -3,
            1,
            -1,
            -2,
            4,
            -4,
            -1,
            -3,
            -4,
            -3,
            3,
            -3,
            -1,
            0,
            0,
            2,
            3,
            -4,
            3,
            4,
            1,
            -3,
            -1,
            3,
            0,
            0,
            1,
            -4,
            -1,
            -2,
            -2,
            2,
            3,
            0,
            1,
            1,
            4,
            1,
            2,
            2,
            4,
            1,
            -2,
            2,
            0,
            3,
            1,
            -3,
            4,
            -3,
            2,
            -1,
            3,
            2,
            -3,
            4,
            3,
            -4,
            -2,
            2,
            4,
            -1,
            3,
            -2,
            -1,
            -4,
            -1,
            -4,
            -3,
            4,
            -1,
            -3,
            -2,
            0,
            -4,
            3,
            -4,
            -1,
            -1,
            4,
            -4,
            0,
            1,
            -1,
            4,
            1,
            -4,
            3,
            4,
            -3,
            -2,
            -2,
            -3,
            0,
            3,
            -1,
            2,
            -4,
            -3,
            -2,
            1,
            -3,
            -3,
            -3,
            1,
            1,
            4,
            -1,
            2,
            4,
            4,
            -3,
            3,
            1,
            -4,
            2,
            -4,
            -3,
            2,
            -4,
            -1,
            3,
            4,
            -4,
            3,
            -3,
            4,
            0,
            -2,
            2,
            1,
            -3,
            1,
            0,
            4,
            2,
            3,
            -2,
            2,
            -2,
            4,
            -1,
            3,
            -2,
            1,
            -3,
            3,
            -3,
            3,
            4,
            1,
            4,
            3,
            3,
            -1,
            0,
            -2,
            1,
            3,
            -4,
            2,
            -1,
            4,
            1,
            0,
            2,
            -1,
            -2,
            1,
            4,
            -4,
            0,
            0,
            3,
            -3,
            1,
            -4,
            4,
            -3,
            1,
            -4,
            3,
            -1,
            2,
            4,
            -1,
            0,
            -4,
            -2,
            4,
            -4,
            4,
            4,
            -2,
            -3,
            3,
            2,
            -2,
            -4,
            -1,
            3,
            1,
            3,
            1,
            -4,
            2,
            -3,
            2,
            4,
            4,
            -3,
            3,
            -4,
            3,
            -4,
            0,
            -2,
            3,
            -3,
            -2,
            3,
            1,
            -4,
            -3,
            3,
            -2,
            -3,
            4,
            -3,
            1,
            1,
            2,
            -1,
            -1,
            0,
            -3,
            -3,
            0,
            -1,
            3
        ];

        int32[N] memory aExpected = [
            -262661,
            -8506629,
            3427761,
            2784265,
            3141917,
            -2372709,
            -8049215,
            -2353801,
            3022212,
            7731946,
            1644566,
            3053540,
            -255898,
            -2738860,
            876613,
            9132009,
            10276178,
            7874020,
            -11588,
            1969958,
            12632850,
            8341150,
            8287818,
            3925510,
            -8773920,
            -747228,
            898118,
            -2317034,
            3897976,
            -4414032,
            -834621,
            4071501,
            -1432521,
            -9685153,
            -13990476,
            -13659378,
            -7289253,
            -7755363,
            3791227,
            -3833707,
            -9487410,
            -8901660,
            -19000363,
            -13214259,
            544413,
            -6844765,
            -6105586,
            -11435970,
            -2978543,
            -1014713,
            -5667934,
            -13166438,
            -5875092,
            -12621756,
            -9964452,
            -5673368,
            -3935130,
            -4224380,
            -7354605,
            -7906865,
            -4353982,
            1618188,
            4762265,
            2833189,
            -310581,
            -3991895,
            -11913640,
            -5312548,
            3570135,
            -4704135,
            -3170969,
            -5592951,
            1453785,
            -4560687,
            -1182968,
            2521098,
            -3751247,
            -4714079,
            301131,
            -2224209,
            -5642042,
            458282,
            5403769,
            2707403,
            12215228,
            5224740,
            6413907,
            6815913,
            4580029,
            425581,
            1318364,
            -783726,
            7326262,
            7568074,
            689180,
            -547668,
            -4653694,
            -11442820,
            -7832628,
            -5377838,
            -11257920,
            -8298570,
            -4596359,
            -4150699,
            -3065694,
            -10682906,
            -2769659,
            937211,
            1653867,
            3120263,
            -1126589,
            7211075,
            -14877134,
            -18262456,
            -8293726,
            -9183292,
            -10773770,
            -6705792,
            -5315674,
            2787012,
            -2270115,
            -9841689,
            -5051871,
            -7388413,
            4234814,
            1052190,
            -2471397,
            -6463519,
            10137330,
            5496024,
            4753901,
            -645043,
            7223139,
            1246181,
            9902026,
            8334682,
            6254834,
            13121436,
            5157886,
            5524544,
            3335176,
            -1444146,
            7151165,
            8213713,
            5425362,
            2999358,
            9659970,
            4975850,
            10923812,
            12903596,
            3807803,
            8025009,
            -5468017,
            -1536129,
            -2185854,
            2751920,
            6580366,
            4468658,
            8981903,
            2405433,
            8513375,
            9863111,
            7777890,
            11623292,
            -484225,
            2094367,
            6670303,
            -1190953,
            -113377,
            7560821,
            -1565727,
            512851,
            2493128,
            -2496028,
            -2851481,
            -11119827,
            -3547676,
            -6187460,
            4743114,
            -1430434,
            8695423,
            404053,
            -5689198,
            -237334,
            -10292594,
            -2482562,
            -4377285,
            -8964791,
            -8246037,
            -13793329,
            -106937,
            -5784361,
            16421657,
            16169825,
            17295701,
            14750529,
            15111685,
            13365139,
            5665684,
            6845556,
            3012973,
            2469901,
            -34925,
            3554251,
            2179597,
            9005783,
            11178922,
            11448090,
            4172918,
            6892142,
            -3097350,
            -2378354,
            -2508563,
            -3588283,
            -7774392,
            -7426678,
            3013820,
            8971556,
            11583329,
            6634515,
            657092,
            6937984,
            -6083813,
            -1488819,
            -1315854,
            5205578,
            -7934583,
            -2186897,
            6308547,
            3324877,
            10276044,
            2595056,
            8209625,
            2358083,
            6005802,
            2915382,
            1471531,
            -1624379,
            -3631962,
            -4158290,
            544917,
            -6606555,
            998696,
            584554,
            1926740,
            844426,
            1017867,
            -3082165,
            -5819081,
            -8499759,
            521737,
            -7231469,
            -4117257,
            -5370457,
            -6235069,
            314971
        ];

        int32[N] memory result = NTT.ntt_internal(a);

        for (uint i = 0; i < N; i++) {
            assertEq(result[i], aExpected[i]);
        }
    }
}
