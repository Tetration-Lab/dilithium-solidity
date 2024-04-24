// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/contract/Dilithium.sol";
import "../src/contract/NttZeta.sol";

contract DilithiumTest is Test {
    Dilithium _dilithium;
    NttZeta _ntt;

    function setUp() public {
        _ntt = new NttZeta();
        _dilithium = new Dilithium(_ntt);
    }

    function test_dilithiumGas() public view {
        Dilithium.PublicKey memory pk = _dilithium.unpack_pk(
            hex"ce267c0717634e4f5593bd7432139e47ae86c948dbd8504b21bd93b2c996d22e5837220b061869ebfa5771c3a450714d42bcf2796a06d1ebddf519771c101cbf987ec8283ab13fdece4428bd6ebae43158ced4f584d3cd29f55d23ff5f58b99d2d2ae77dd0bb8cdc0092dfb8bca94c7bc80fc595a77a8a76b856604dd759153e5be002ddc4d824de9192e11eab3a59366bc7ab2867fb29d4bd59fa4d0f627887435272584fd31a4b2dea5775266fa9869e3a57bb7da2d7111e610ddc1ce9c0b1befa5d26b0d5bc865c4422d73e11236796b0bce9b3ae55915d6a47fe29335199719eeb2b63f621e9ce3a7df5129a95796d065ecb204269c3b792ee94b00f8316c3bd1ca3b2527f9634d191aa42a85e31238bba5da1e36d553f059a49ebff004c8b9995751cfdf3e0f258ba50e64b376315275b5c3b69b2ab7ad188a763ea1bf3a790bdcad897a2835d4c97ae2254d5fe5e92cf097b23e484ccb6adf42a4d1d1bea772eea52116f2a17b27c35565c0dfd7bb5be747a767f7bd0e518e44686a416d648fade20f694546d612ad97b7edc451ab8b7eed456f4b25b8c88e31c91472e9db99a8e00462b14939d5d3ea11f82a97438ec2cf667dd19e049b9af97480a82a137c036b3c1700d604d2b81164524a692bc35251a8242cb1d2ea22aa9aad90994e404b9c220629e96144bf83591474d4a961c8023b2fd8401a2a0db381996de7b5c36483ce8186f8b0d65790e6209a076104dcefa6f30db5d1eeca0b1027ecfbfa56db3bc4ba924caec8a6faf7ef60e1a5d291edd67b1616be10e6e0bf5dd4dfdff8ffdcde527fe1f608590c67a2521aded3ae4a67249b318049892fc88dbf44c4c12aab1e7d1e11d0cd62ecc47ce3d64a5538032817ba56049b2406220c5128c577e1132061c07c7f62fdaac9bf982d7ed00898b839d85a71d4bd946b76418173f2703c2b5869ccdd2b44e2a42e864f63b695b7ec575e5c36d580bac76ed087c3bd1642134513df2916c96faf70451c69c2eba418c440068e08de52b3ee7a4be0c48ae9a228583cc3c3e40aaa9c0e55d77628c9965b83113a15b9b38b92724ff0def3facf55e385a717f11821263135736ba18eb3638acea4ffebee60dba0e049d341fe438b29ad00404e96ddbba626d180772ece2d08bec2d251a30730c6afda766f3bfe8482fdfc6778c20a8a4a1a64e11b6d6cb16a568df1cb7372fd5635c1c38de8bc7669f5eb6fa9458f40b9715cd4bda1af6a3e3ee5d25e54a297d4f2a8c053c3be937b2c01184bb5533ee804e8e7744ca3dfb34a5008bc2160356c310aa333a124450cc7cca7f4e9ed764699f2112c382fef0b2444cad0b3771ec9e5f37b4ab6f4524effb47333d522b6e8110170a76fcbc53a76a0a17ad79ea80c773170dda050b435ccf607d66e1217aaaca983e041bd5f9fc210a85eb911fc12643e546ac4cc9b875d097bb12cd017e9ca19e5bb309e400a2ec3ea09a6a61dcf109acaacb97e6b5560cc930d519b9e3b5babbd027d68b44059cea543363a0d636d6f036272c4460b4731a58ca0b6bd442cb024b14f9bad25989b916f65d5a58948b1adba9debe438317e32f9e24b75dda327f1a9ed50b87b1970d3e3fa10d1781935ed8b4c209e8b4e6d2d9788d124e8ed61fbd2f0c8b98c78e39ef9c2c7046d927623e3a71db17c9c63ae9c5b11ec2c722b53ee3c362a51a0c9c607233ba3d8106f1a6fa3de026fd062ac60c3cd53263889439d5aaf0a042b1951532c6bf063ce00b5d69891b2348f87f9bf8da1d0938bf49415581b5c98456adee674ce98656e63c9ab0762d72abf0ec54c6b0e87dec92b08a805ef076a2cbc77690013e6056"
        );
        Dilithium.ExpandedPublicKey memory epk = _dilithium.expand(pk);
        Dilithium.Signature memory sig = _dilithium.unpack_sig(
            hex"5505e19b47551e619823613c4ad55ec9b396f298b2f762a7ecd71a7bef1a6d92fb756e1b581f1ee5f9c866e48eeffdea24890fb524f2674fb9a5228e216bbcda494efaf1de3724a09247b708972589636c1da42218a43c376498c7be38244a261367b4334aadfab06bf9f2db43f5a27349d4d96efe363aab22625e195ad026736c3bbabe13dd50ecb195478a84f9e0c875413314beff076459878955155b41dccedddc5887a565a34e7473e97346563862d4bdc1c7cedbe340b633f22a1e7d86fbe2efef69191640a0260f5969f0dfc7c0e366b4bc255637617d9e45eb7c32576a24e36c2fc618869e8f47b1c9770b7be21b1f0088b97c2114fb1b835215dc82336d87a6f83fadf901a1dc17e895b4bc12eef7e54382e8fcd9601c64dda2a257990ed20ee6f56a32af97e0303821a4ffec4794a1671cffcf90e69e9f70b94dc3fb098d21412b2fbfdead3700a4a76287772aa0ff0ac44bb5f5797577485d867c27aeb98d07979792361332f9388451a48d5f2e84f902076e8fdf93a8f28707237e109496efc78b2ae48b8bd8d0d4331a2c48f71a6f741f7817a8dddd2cbd8e6bf2b2d9eafdff08b243013151d74a84d2cbdc118fc095b63d1fa8ecb12b2ceed085bf19cf6b8482619405804783e3e1f131fbc1142a5feed3dd0991621495afbed674fc1ebb593ddfaeca90f2e3b3b657289c41239bd7a7c9c8c515933c01fe6eebd12ffdfda46ea341fd6beab26309453e79e97a92e1de5fcd2db001e80dba5ae2df53e071dbe55e76136da642d5e257b5e10b6d270157c24e5f51c0d5fd0c298da4001e51ce1094f696a608b5882331c63825c0272844feabe9c6110be746fbf6493faf682e527879927b6ab7afd85d5b6193875846fbd97fb86bbd145ea0a373928ee9a2eccbf452f0ecc766431d42b21b194003c6a7ab23dade35bb55edfbfda982853d7d14331ceada9f6803be9adc1cfa6b8a9eb65085224e1e2614f8bc75d57d951c6ed8119a3399e094354cb03189de49ede5334e60c58135da41ef80dcc74066f23b4d3d8f2e91fd80e959c09dfb9fe9421fbb7655f6a2641ca5795be222699feec44d16389a81504f19a47e33ef82afd2004fcdb50ac917426327cb4d2fc45eadf935f69282b45d10176286785d614d9887bb1604103b75882fa1754d2b6c97848add14ded0e86ebaec4017c3ebd1c9f9dd18c41cc73b171edaa86de9e6cafd6b17f7e70ee02929f435cb2ac53d32d2fe9a8a780da69ca5116cccf8fd15a57091aeff9a1d679d11e38cd9d24629aea4f379ae9e214d01409d14687512a0cdf7703a73b3b4fb816b1bc949a55ffcd02187f0a24a3e407dabb0e033c20fe5ad9fd84a5b2180b2b49ef91271209c755ce85209502c5d1a5a2b0bde5b409c04f79828f33d6cdb5d4d41ceb9ded3c71e4b1f7aec33763d8e9ea11af213d405d7bd5cd4243c0aec4fb2453c98ff639ea33f23c17049697b06f9219a0545071191d2eb6117d73397fe2bf12cec5fa5ea1db5d07278495d6484486df4ee2f40c2962536f59343f86990a9180722574760359d8d91a75cea09f61b545026247bd5d58dca7e42e889ded3235ef4b4371f254159d265067d89194f05d8e46421d73d8e16c4c236b93d58591e70497f6e8c42738d6be09b0b3470b1ddfc8012acc05b406cd61f4c7c899faf2309e5fb5847fdcb490c7e55f6244605809eacb51d4d25382f5540c48ca63b70249429fc7c79f48c2838005b462d8e2fab7a0657e2b688af7a5136d9dea83e40d1e0a0e78cd4607bd31ae25cc0708f34cb65997205a9b846dc806191f2f233813a3fb86fd4ba83e7b03a16eeff09be3f2b5e1736f67988d5ff408fc2977a291bb9638ea1356ee508e08f3e598a5283c5000a42940ae7721199cad08c94d043d08240ba7f485328c1094165008597f10ec9381d1749274422e3c60c666f1d81bab7fa84b11b974431743fbcf203c7c44ca7c3b877ba70f9fe46dd669cf33d4646ebb65ba2d1b467c57032ec4d506dd2f1d8094306a0c79a5af010f9d34d9fdd84744254add8dd5b912754792e600ec336419cb95b398c5ff06b9eeb7bf46fc17ce1de90eddfc1499d1c7c7f95c8eeaa99fc2431e6e3343558454d050842dfaa5bf16f09d3501f4c85b905855097643f8fd1e512d01721e195f2f0ddcd3dbfe0e2b2d7a573b511e7547f894f2a80504bb7dc5005ef1bb8c6ae5ff15e5aeb520fb4c82d651b7e64cd61d0f0d3ca6529b6fc531d13a4372c3a95b6e4c43f1cb9486a881600a42c334008229c10811d4e8d810f78e0d2356b698c434ff98fd0f999c5d6f82225cee96f7da4e895572193f8cfc3cdfbf848975d4588cb5e7244ae25b5356bad8f5a85f7eba3e6ecf5d457770762bc1bb773ac052b3f9adca690540917be7bb0954253305fd82caddd00873f2c19b538058fda6c9e451190497a27bec345577ae7607a1ad7c732b967fa3addf57f6302b87d8441432a5fd93e0aa27ee481a96b167250e89446dad17bf27d8818ab6c98ee54a0e3b8d5902b36e3ee56e7b7f2d4340a52d2ff962704894e1ed9e757d7d5a2a54a895c93b4328c38ec51b6d05cf4cc8f86b14b2bc095037774e5075330c0393aca247d5514e8004909b84351ef1b361349f314589bdbc3dd441ba5d543c43b20be8e1255a12f147eee3b72d3380561904a0b3b9ac1f95fd052f13142e2487ba1d5116af780e49caac90c36481f10355bbbb53c206b6aad3c953d1c0b15292346bd18389c451cf38719a5afc00ad01f444f14bc2ba0c905f80ddde078529e6c2a3f106e05a98eb675fa88cd5944aa7de0036f6845108401a6ff8b3fcdbc5cb29b5a693954282fc9671d1b14ce0c8108521b52438b4d70abbf4de1d9373ffd0bdc7749ed167b0bacfc561c689691d5bfef76cd485fadf1aacc82bbcf35dce7cedecee7f3c7f26a51898e45b94afa63ae71ec8f0ba4b10efd02ac00bf9614c69e965e9b677d0a012823922055edce1a9bae2608ab7eff87c56f514aa61aa9cf1ad8ec97138d5564e4116c6b29ea9ee95061f4aa283a4ee4f198820da8f440de343d8d17806578c96f26d8b89639cbbfc03e12d672afe629924acba603d545aec6cff9b692ec8c1c62ffc66436f1028a18f8ea4e1b739f5e9015b8a507cdf12d56e859c11a3c9ae6042fe55b977cc4035182f2def7e428aaf0fe57e0d9cd922158e9d9272e46a11722d6ffadab58c2fa074e294f5727ebd857349e742d598d66d414c8bae14d3fdc1e81366350e51558bd6db09ae36153dd52eb4fb9896374af199c540a0f363f4759677e868896afb7d8d90b0e253c416172888b99a8c2d9f21424494d657ea4b9cbda070e1838449aa3a6b0b2c0d9e7fa0000000000000000000000000000000000000000000000000000000f1d2735"
        );
        bytes memory m = hex"48656c6c6f"; // Hello

        bool _result = _dilithium.verifyExpanded(sig, epk, m);
        assert(_result);
    }

    function test_dilithiumGasBytes() public view {
        Dilithium.PublicKey memory pk = _dilithium.unpack_pk(
            hex"ce267c0717634e4f5593bd7432139e47ae86c948dbd8504b21bd93b2c996d22e5837220b061869ebfa5771c3a450714d42bcf2796a06d1ebddf519771c101cbf987ec8283ab13fdece4428bd6ebae43158ced4f584d3cd29f55d23ff5f58b99d2d2ae77dd0bb8cdc0092dfb8bca94c7bc80fc595a77a8a76b856604dd759153e5be002ddc4d824de9192e11eab3a59366bc7ab2867fb29d4bd59fa4d0f627887435272584fd31a4b2dea5775266fa9869e3a57bb7da2d7111e610ddc1ce9c0b1befa5d26b0d5bc865c4422d73e11236796b0bce9b3ae55915d6a47fe29335199719eeb2b63f621e9ce3a7df5129a95796d065ecb204269c3b792ee94b00f8316c3bd1ca3b2527f9634d191aa42a85e31238bba5da1e36d553f059a49ebff004c8b9995751cfdf3e0f258ba50e64b376315275b5c3b69b2ab7ad188a763ea1bf3a790bdcad897a2835d4c97ae2254d5fe5e92cf097b23e484ccb6adf42a4d1d1bea772eea52116f2a17b27c35565c0dfd7bb5be747a767f7bd0e518e44686a416d648fade20f694546d612ad97b7edc451ab8b7eed456f4b25b8c88e31c91472e9db99a8e00462b14939d5d3ea11f82a97438ec2cf667dd19e049b9af97480a82a137c036b3c1700d604d2b81164524a692bc35251a8242cb1d2ea22aa9aad90994e404b9c220629e96144bf83591474d4a961c8023b2fd8401a2a0db381996de7b5c36483ce8186f8b0d65790e6209a076104dcefa6f30db5d1eeca0b1027ecfbfa56db3bc4ba924caec8a6faf7ef60e1a5d291edd67b1616be10e6e0bf5dd4dfdff8ffdcde527fe1f608590c67a2521aded3ae4a67249b318049892fc88dbf44c4c12aab1e7d1e11d0cd62ecc47ce3d64a5538032817ba56049b2406220c5128c577e1132061c07c7f62fdaac9bf982d7ed00898b839d85a71d4bd946b76418173f2703c2b5869ccdd2b44e2a42e864f63b695b7ec575e5c36d580bac76ed087c3bd1642134513df2916c96faf70451c69c2eba418c440068e08de52b3ee7a4be0c48ae9a228583cc3c3e40aaa9c0e55d77628c9965b83113a15b9b38b92724ff0def3facf55e385a717f11821263135736ba18eb3638acea4ffebee60dba0e049d341fe438b29ad00404e96ddbba626d180772ece2d08bec2d251a30730c6afda766f3bfe8482fdfc6778c20a8a4a1a64e11b6d6cb16a568df1cb7372fd5635c1c38de8bc7669f5eb6fa9458f40b9715cd4bda1af6a3e3ee5d25e54a297d4f2a8c053c3be937b2c01184bb5533ee804e8e7744ca3dfb34a5008bc2160356c310aa333a124450cc7cca7f4e9ed764699f2112c382fef0b2444cad0b3771ec9e5f37b4ab6f4524effb47333d522b6e8110170a76fcbc53a76a0a17ad79ea80c773170dda050b435ccf607d66e1217aaaca983e041bd5f9fc210a85eb911fc12643e546ac4cc9b875d097bb12cd017e9ca19e5bb309e400a2ec3ea09a6a61dcf109acaacb97e6b5560cc930d519b9e3b5babbd027d68b44059cea543363a0d636d6f036272c4460b4731a58ca0b6bd442cb024b14f9bad25989b916f65d5a58948b1adba9debe438317e32f9e24b75dda327f1a9ed50b87b1970d3e3fa10d1781935ed8b4c209e8b4e6d2d9788d124e8ed61fbd2f0c8b98c78e39ef9c2c7046d927623e3a71db17c9c63ae9c5b11ec2c722b53ee3c362a51a0c9c607233ba3d8106f1a6fa3de026fd062ac60c3cd53263889439d5aaf0a042b1951532c6bf063ce00b5d69891b2348f87f9bf8da1d0938bf49415581b5c98456adee674ce98656e63c9ab0762d72abf0ec54c6b0e87dec92b08a805ef076a2cbc77690013e6056"
        );
        Dilithium.ExpandedPublicKey memory epk = _dilithium.expand(pk);
        bytes
            memory sig = hex"5505e19b47551e619823613c4ad55ec9b396f298b2f762a7ecd71a7bef1a6d92fb756e1b581f1ee5f9c866e48eeffdea24890fb524f2674fb9a5228e216bbcda494efaf1de3724a09247b708972589636c1da42218a43c376498c7be38244a261367b4334aadfab06bf9f2db43f5a27349d4d96efe363aab22625e195ad026736c3bbabe13dd50ecb195478a84f9e0c875413314beff076459878955155b41dccedddc5887a565a34e7473e97346563862d4bdc1c7cedbe340b633f22a1e7d86fbe2efef69191640a0260f5969f0dfc7c0e366b4bc255637617d9e45eb7c32576a24e36c2fc618869e8f47b1c9770b7be21b1f0088b97c2114fb1b835215dc82336d87a6f83fadf901a1dc17e895b4bc12eef7e54382e8fcd9601c64dda2a257990ed20ee6f56a32af97e0303821a4ffec4794a1671cffcf90e69e9f70b94dc3fb098d21412b2fbfdead3700a4a76287772aa0ff0ac44bb5f5797577485d867c27aeb98d07979792361332f9388451a48d5f2e84f902076e8fdf93a8f28707237e109496efc78b2ae48b8bd8d0d4331a2c48f71a6f741f7817a8dddd2cbd8e6bf2b2d9eafdff08b243013151d74a84d2cbdc118fc095b63d1fa8ecb12b2ceed085bf19cf6b8482619405804783e3e1f131fbc1142a5feed3dd0991621495afbed674fc1ebb593ddfaeca90f2e3b3b657289c41239bd7a7c9c8c515933c01fe6eebd12ffdfda46ea341fd6beab26309453e79e97a92e1de5fcd2db001e80dba5ae2df53e071dbe55e76136da642d5e257b5e10b6d270157c24e5f51c0d5fd0c298da4001e51ce1094f696a608b5882331c63825c0272844feabe9c6110be746fbf6493faf682e527879927b6ab7afd85d5b6193875846fbd97fb86bbd145ea0a373928ee9a2eccbf452f0ecc766431d42b21b194003c6a7ab23dade35bb55edfbfda982853d7d14331ceada9f6803be9adc1cfa6b8a9eb65085224e1e2614f8bc75d57d951c6ed8119a3399e094354cb03189de49ede5334e60c58135da41ef80dcc74066f23b4d3d8f2e91fd80e959c09dfb9fe9421fbb7655f6a2641ca5795be222699feec44d16389a81504f19a47e33ef82afd2004fcdb50ac917426327cb4d2fc45eadf935f69282b45d10176286785d614d9887bb1604103b75882fa1754d2b6c97848add14ded0e86ebaec4017c3ebd1c9f9dd18c41cc73b171edaa86de9e6cafd6b17f7e70ee02929f435cb2ac53d32d2fe9a8a780da69ca5116cccf8fd15a57091aeff9a1d679d11e38cd9d24629aea4f379ae9e214d01409d14687512a0cdf7703a73b3b4fb816b1bc949a55ffcd02187f0a24a3e407dabb0e033c20fe5ad9fd84a5b2180b2b49ef91271209c755ce85209502c5d1a5a2b0bde5b409c04f79828f33d6cdb5d4d41ceb9ded3c71e4b1f7aec33763d8e9ea11af213d405d7bd5cd4243c0aec4fb2453c98ff639ea33f23c17049697b06f9219a0545071191d2eb6117d73397fe2bf12cec5fa5ea1db5d07278495d6484486df4ee2f40c2962536f59343f86990a9180722574760359d8d91a75cea09f61b545026247bd5d58dca7e42e889ded3235ef4b4371f254159d265067d89194f05d8e46421d73d8e16c4c236b93d58591e70497f6e8c42738d6be09b0b3470b1ddfc8012acc05b406cd61f4c7c899faf2309e5fb5847fdcb490c7e55f6244605809eacb51d4d25382f5540c48ca63b70249429fc7c79f48c2838005b462d8e2fab7a0657e2b688af7a5136d9dea83e40d1e0a0e78cd4607bd31ae25cc0708f34cb65997205a9b846dc806191f2f233813a3fb86fd4ba83e7b03a16eeff09be3f2b5e1736f67988d5ff408fc2977a291bb9638ea1356ee508e08f3e598a5283c5000a42940ae7721199cad08c94d043d08240ba7f485328c1094165008597f10ec9381d1749274422e3c60c666f1d81bab7fa84b11b974431743fbcf203c7c44ca7c3b877ba70f9fe46dd669cf33d4646ebb65ba2d1b467c57032ec4d506dd2f1d8094306a0c79a5af010f9d34d9fdd84744254add8dd5b912754792e600ec336419cb95b398c5ff06b9eeb7bf46fc17ce1de90eddfc1499d1c7c7f95c8eeaa99fc2431e6e3343558454d050842dfaa5bf16f09d3501f4c85b905855097643f8fd1e512d01721e195f2f0ddcd3dbfe0e2b2d7a573b511e7547f894f2a80504bb7dc5005ef1bb8c6ae5ff15e5aeb520fb4c82d651b7e64cd61d0f0d3ca6529b6fc531d13a4372c3a95b6e4c43f1cb9486a881600a42c334008229c10811d4e8d810f78e0d2356b698c434ff98fd0f999c5d6f82225cee96f7da4e895572193f8cfc3cdfbf848975d4588cb5e7244ae25b5356bad8f5a85f7eba3e6ecf5d457770762bc1bb773ac052b3f9adca690540917be7bb0954253305fd82caddd00873f2c19b538058fda6c9e451190497a27bec345577ae7607a1ad7c732b967fa3addf57f6302b87d8441432a5fd93e0aa27ee481a96b167250e89446dad17bf27d8818ab6c98ee54a0e3b8d5902b36e3ee56e7b7f2d4340a52d2ff962704894e1ed9e757d7d5a2a54a895c93b4328c38ec51b6d05cf4cc8f86b14b2bc095037774e5075330c0393aca247d5514e8004909b84351ef1b361349f314589bdbc3dd441ba5d543c43b20be8e1255a12f147eee3b72d3380561904a0b3b9ac1f95fd052f13142e2487ba1d5116af780e49caac90c36481f10355bbbb53c206b6aad3c953d1c0b15292346bd18389c451cf38719a5afc00ad01f444f14bc2ba0c905f80ddde078529e6c2a3f106e05a98eb675fa88cd5944aa7de0036f6845108401a6ff8b3fcdbc5cb29b5a693954282fc9671d1b14ce0c8108521b52438b4d70abbf4de1d9373ffd0bdc7749ed167b0bacfc561c689691d5bfef76cd485fadf1aacc82bbcf35dce7cedecee7f3c7f26a51898e45b94afa63ae71ec8f0ba4b10efd02ac00bf9614c69e965e9b677d0a012823922055edce1a9bae2608ab7eff87c56f514aa61aa9cf1ad8ec97138d5564e4116c6b29ea9ee95061f4aa283a4ee4f198820da8f440de343d8d17806578c96f26d8b89639cbbfc03e12d672afe629924acba603d545aec6cff9b692ec8c1c62ffc66436f1028a18f8ea4e1b739f5e9015b8a507cdf12d56e859c11a3c9ae6042fe55b977cc4035182f2def7e428aaf0fe57e0d9cd922158e9d9272e46a11722d6ffadab58c2fa074e294f5727ebd857349e742d598d66d414c8bae14d3fdc1e81366350e51558bd6db09ae36153dd52eb4fb9896374af199c540a0f363f4759677e868896afb7d8d90b0e253c416172888b99a8c2d9f21424494d657ea4b9cbda070e1838449aa3a6b0b2c0d9e7fa0000000000000000000000000000000000000000000000000000000f1d2735";
        bytes memory m = hex"48656c6c6f"; // Hello

        bool _result = _dilithium.verifyExpandedBytes(sig, epk, m);
        assert(_result);
    }
}
