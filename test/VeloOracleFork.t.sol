pragma solidity ^0.8.13;

import "../contracts/VeloOracle.sol";
import "forge-std/Test.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title VeloOracleForkTest
/// @author velodrome.finance, @AkemiHomura-maow
/// @notice A forked integration Foundry test contract for VeloOracle
contract VeloOracleForkTest is Test {
    address[] private connectors;
    address private USDC;
    VeloOracle private oracle;
    uint256 private optimismFork;

    /// @dev All tests in this contract should run at the block height of 108000000 on Optimism mainnet.
    /// The same set of connector tokens is shared among all tests in this contract.
    function setUp() public {
        optimismFork = vm.createFork(vm.envString("OPTIMISM_RPC_URL"), 108000000);
        USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
        oracle = VeloOracle(0x395942C2049604a314d39F370Dfb8D87AAC89e16);
        vm.label(0x2513486f18eeE1498D7b6281f668B955181Dd0D9, "xOpenx");
        vm.label(0xc40F949F8a4e094D1b49a23ea9241D289B7b2819, "LUSD");
        vm.label(0x9e5AAC1Ba1a2e6aEd6b32689DFcF62A509Ca96f3, "DF");
        vm.label(0x6806411765Af15Bddd26f8f544A34cC40cb9838B, "frxETH");
        vm.label(0x3A18dcC9745eDcD1Ef33ecB93b0b6eBA5671e7Ca, "KUJI");
        vm.label(0x9e1028F5F1D5eDE59748FFceE5532509976840E0, "PERP");
        vm.label(0x10010078a54396F62c96dF8532dc2B4847d47ED3, "HND");
        vm.label(0x4200000000000000000000000000000000000006, "WETH");
        vm.label(0x2E3D870790dC77A83DD1d18184Acc7439A53f475, "FRAX");
        vm.label(0x8aE125E8653821E851F12A49F7765db9a9ce7384, "DOLA");
        vm.label(0xFdb794692724153d1488CcdBE0C56c252596735F, "LDO");
        vm.label(0x3417E54A51924C225330f8770514aD5560B9098D, "RED");
        vm.label(0x79AF5dd14e855823FA3E9ECAcdF001D99647d043, "jEUR");
        vm.label(0xC26921B5b9ee80773774d36C84328ccb22c3a819, "wOptiDoge");
        vm.label(0x9Bcef72be871e61ED4fBbc7630889beE758eb81D, "rETH");
        vm.label(0x12ff4a259e14D4DCd239C447D23C9b00F7781d8F, "PEPE Optimism");
        vm.label(0x94b008aA00579c1307B0EF2c499aD98a8ce58e58, "USDT");
        vm.label(0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9, "sUSD");
        vm.label(0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4, "SNX");
        vm.label(0x1DB2466d9F5e10D7090E7152B68d62703a2245F0, "SONNE");
        vm.label(0xC03b43d492d904406db2d7D57e67C7e8234bA752, "wUSDR");
        vm.label(0xAF9fE3B5cCDAe78188B1F8b9a49Da7ae9510F151, "DHT");
        vm.label(0xc3864f98f2a61A7cAeb95b039D031b4E2f55e0e9, "OpenX");
        vm.label(0x747e42Eb0591547a0ab429B3627816208c734EA7, "T");
        vm.label(0x970D50d09F3a656b43E11B0D45241a84e3a6e011, "DAI+");
        vm.label(0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49, "sETH");
        vm.label(0x7aE97042a4A0eB4D1eB370C34BfEC71042a056B7, "UNLOCK");
        vm.label(0x88a89866439F4C2830986B79cbe6f69d1Bd548BB, "BIKE");
        vm.label(0x9560e827aF36c94D2Ac33a39bCE1Fe78631088Db, "VELO");
        vm.label(0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb, "LYRA");
        vm.label(0x920Cf626a271321C151D027030D5d08aF699456b, "KWENTA");
        vm.label(0x15e770B95Edd73fD96b02EcE0266247D50895E76, "JRT");
        vm.label(0x676f784d19c7F1Ac6C6BeaeaaC78B02a73427852, "OPP");
        vm.label(0x4200000000000000000000000000000000000042, "OP");
        vm.label(0x217D47011b23BB961eB6D93cA9945B7501a5BB11, "THALES");
        vm.label(0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb, "wstETH");
        vm.label(0x2dAD3a13ef0C6366220f989157009e501e7938F8, "EXTRA");
        vm.label(0xc38464250F51123078BBd7eA574E185F6623d037, "opxVELO");
        vm.label(0x296F55F8Fb28E498B858d0BcDA06D955B2Cb3f97, "STG");
        vm.label(0x9485aca5bbBE1667AD97c7fE7C4531a624C8b1ED, "agEUR");
        vm.label(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, "DAI");
        vm.label(0x68f180fcCe6836688e9084f035309E29Bf0A2095, "WBTC");
        vm.label(0x484c2D6e3cDd945a8B2DF735e079178C1036578c, "sfrxETH");
        vm.label(0x00a35FD824c717879BF370E70AC6868b95870Dfb, "IB");
        vm.label(0xC1c167CC44f7923cd0062c4370Df962f9DDB16f5, "PEPE");
        vm.label(0x3F56e0c36d275367b8C502090EDF38289b3dEa0d, "QI");
        vm.label(0x1F514A61bcde34F94Bc39731235690ab9da737F7, "TAROT");
        vm.label(0x9a2e53158e12BC09270Af10C16A466cb2b5D7836, "MET");
        vm.label(0xdC6fF44d5d932Cbd77B52E5612Ba0529DC6226F1, "WLD");
        vm.label(0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC, "HOP");
        vm.label(0xfDeFFc7Ad816BF7867C642dF7eBC2CC5554ec265, "beVELO");
        vm.label(0xB0ae108669CEB86E9E98e8fE9e40d98b867855fD, "RING");
        vm.label(0x3E29D3A9316dAB217754d13b28646B76607c5f04, "alETH");
        vm.label(0xE3AB61371ECc88534C522922a026f2296116C109, "SPELL");
        vm.label(0x46f21fDa29F1339e0aB543763FF683D399e393eC, "opxveVELO");
        vm.label(0x61BAADcF22d2565B0F471b291C475db5555e0b76, "AELIN");
        vm.label(0xc5b001DC33727F8F26880B184090D3E252470D45, "ERN");
        vm.label(0x7F5c764cBc14f9669B88837ca1490cCa17c31607, "USDC");
        vm.label(0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40, "tBTC");
        vm.label(0xCB8FA9a76b8e203D8C3797bF438d8FB81Ea3326A, "alUSD");
        vm.label(0x1e925De1c68ef83bD98eE3E130eF14a50309C01B, "EXA");
        vm.label(0x929B939f8524c3Be977af57A4A0aD3fb1E374b50, "MTA");
        vm.label(0x39FdE572a18448F8139b7788099F0a0740f51205, "OATH");
        vm.label(0xdFA46478F9e5EA86d57387849598dbFB2e964b02, "MAI");
        vm.label(0xB0B195aEFA3650A6908f15CdaC7D92F8a5791B0B, "BOB");
        vm.label(0xdb4eA87fF83eB1c80b8976FC47731Da6a31D35e5, "wTBT");
        vm.label(0xB153FB3d196A8eB25522705560ac152eeEc57901, "MIM");
        vm.label(0x74ccbe53F77b08632ce0CB91D3A545bF6B8E0979, "fBOMB");
        vm.label(0xa50B23cDfB2eC7c590e84f403256f67cE6dffB84, "BLU");
        vm.label(0x73cb180bf0521828d8849bc8CF2B920918e23032, "USD+");
        vm.label(0x1610e3c85dd44Af31eD7f33a63642012Dca0C5A5, "msETH");
        vm.label(0x4E720DD3Ac5CFe1e1fbDE4935f386Bb1C66F4642, "BIFI");
        vm.label(0xCa0E54b636DB823847B29F506BFFEE743F57729D, "CHI");
        vm.label(0x6c2f7b6110a37b3B0fbdd811876be368df02E8B0, "RETH");
        vm.label(0x28b42698Caf46B4B012CF38b6C75867E0762186D, "UNIDX");
        vm.label(0xbfD291DA8A403DAAF7e5E9DC1ec0aCEaCd4848B9, "USX");
        connectors.push(0x9560e827aF36c94D2Ac33a39bCE1Fe78631088Db);
        connectors.push(0x4200000000000000000000000000000000000042);
        connectors.push(0x4200000000000000000000000000000000000006);
        connectors.push(0x9Bcef72be871e61ED4fBbc7630889beE758eb81D);
        connectors.push(0x2E3D870790dC77A83DD1d18184Acc7439A53f475);
        connectors.push(0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9);
        connectors.push(0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb);
        connectors.push(0xbfD291DA8A403DAAF7e5E9DC1ec0aCEaCd4848B9);
        connectors.push(0xc3864f98f2a61A7cAeb95b039D031b4E2f55e0e9);
        connectors.push(0x9485aca5bbBE1667AD97c7fE7C4531a624C8b1ED);
        connectors.push(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
        connectors.push(0x73cb180bf0521828d8849bc8CF2B920918e23032);
        connectors.push(0x6806411765Af15Bddd26f8f544A34cC40cb9838B);
        connectors.push(0x6c2f7b6110a37b3B0fbdd811876be368df02E8B0);
        connectors.push(0xc5b001DC33727F8F26880B184090D3E252470D45);
        connectors.push(0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40);
    }

    /// @dev tokens[i]        : Address of a query token.
    ///      referenceRates[i]: Ground truth rate of tokens[i]
    /// The tests first assemble the input arrays to VeloOracle, by concatenating [query_tokens, conncectors, quote_token] to one single array.
    /// The quote token is USDC across all tests.
    /// The tests then compare whether the returned rates are within ±2% of referenceRates, if not then an Assertion Error would be thrown by Foundry.
    /// A sample error log:
    /// [FAIL. Reason: Assertion failed.] testFork_Integration_GetManyRatesWithConnectors_Batch16() (gas: 575770)
    /// Logs:
    ///   Error: WBTC: returned rate too low
    ///   Error: a >= b not satisfied [uint]
    ///     Value a: 73678710360056675612
    ///     Value b: 29145278380188217733283
    function testFork_Integration_GetManyRatesWithConnectors_Batch1() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(1000000000000000000),
            uint256(998634134135795712),
            uint256(511789203089245056),
            uint256(16728374196070304),
            uint256(1857375843193731678208)
        ];
        address[5] memory tokens = [
            0x7F5c764cBc14f9669B88837ca1490cCa17c31607,
            0xc40F949F8a4e094D1b49a23ea9241D289B7b2819,
            0x9e1028F5F1D5eDE59748FFceE5532509976840E0,
            0x10010078a54396F62c96dF8532dc2B4847d47ED3,
            0x4200000000000000000000000000000000000006
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch2() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(995755882315754112),
            uint256(999767797416584064),
            uint256(2609101024360673792),
            uint256(140716301317346672),
            uint256(1070148841630821760)
        ];
        address[5] memory tokens = [
            0x8aE125E8653821E851F12A49F7765db9a9ce7384,
            0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9,
            0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4,
            0x1DB2466d9F5e10D7090E7152B68d62703a2245F0,
            0xC03b43d492d904406db2d7D57e67C7e8234bA752
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch3() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(105999333644331664),
            uint256(63611978996055096),
            uint256(1620381049228263680),
            uint256(35525053785213748),
            uint256(627037053093260032)
        ];
        address[5] memory tokens = [
            0x9560e827aF36c94D2Ac33a39bCE1Fe78631088Db,
            0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb,
            0x4200000000000000000000000000000000000042,
            0x2dAD3a13ef0C6366220f989157009e501e7938F8,
            0x296F55F8Fb28E498B858d0BcDA06D955B2Cb3f97
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch4() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(1095873397137483264),
            uint256(999387426949441792),
            uint256(91145050928450384),
            uint256(990956022105817600),
            uint256(36914437271134896)
        ];
        address[5] memory tokens = [
            0x9485aca5bbBE1667AD97c7fE7C4531a624C8b1ED,
            0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1,
            0x1F514A61bcde34F94Bc39731235690ab9da737F7,
            0xCB8FA9a76b8e203D8C3797bF438d8FB81Ea3326A,
            0x929B939f8524c3Be977af57A4A0aD3fb1E374b50
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch5() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(35843196414505160),
            uint256(982290327062152832),
            uint256(1000017852054637952),
            uint256(1019355257237337216),
            uint256(996155106351093632)
        ];
        address[5] memory tokens = [
            0x39FdE572a18448F8139b7788099F0a0740f51205,
            0xdFA46478F9e5EA86d57387849598dbFB2e964b02,
            0xB0B195aEFA3650A6908f15CdaC7D92F8a5791B0B,
            0xdb4eA87fF83eB1c80b8976FC47731Da6a31D35e5,
            0xB153FB3d196A8eB25522705560ac152eeEc57901
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch6() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(23382210255948120),
            uint256(998642791938403840),
            uint256(997026466583745152),
            uint256(36076962368839728),
            uint256(1851673921366254157824)
        ];
        address[5] memory tokens = [
            0xa50B23cDfB2eC7c590e84f403256f67cE6dffB84,
            0x73cb180bf0521828d8849bc8CF2B920918e23032,
            0xbfD291DA8A403DAAF7e5E9DC1ec0aCEaCd4848B9,
            0x9e5AAC1Ba1a2e6aEd6b32689DFcF62A509Ca96f3,
            0x6806411765Af15Bddd26f8f544A34cC40cb9838B
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch7() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(995763013467908736),
            uint256(3480817664357965824),
            uint256(1095885447583169920),
            uint256(1780661812675),
            uint256(2013856101169050943488)
        ];
        address[5] memory tokens = [
            0x2E3D870790dC77A83DD1d18184Acc7439A53f475,
            0x3417E54A51924C225330f8770514aD5560B9098D,
            0x79AF5dd14e855823FA3E9ECAcdF001D99647d043,
            0xC26921B5b9ee80773774d36C84328ccb22c3a819,
            0x9Bcef72be871e61ED4fBbc7630889beE758eb81D
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch8() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(35622899110079),
            uint256(999539426308483712),
            uint256(97782735314826176),
            uint256(32179084529318176),
            uint256(22848158041867596)
        ];
        address[5] memory tokens = [
            0x12ff4a259e14D4DCd239C447D23C9b00F7781d8F,
            0x94b008aA00579c1307B0EF2c499aD98a8ce58e58,
            0xAF9fE3B5cCDAe78188B1F8b9a49Da7ae9510F151,
            0xc3864f98f2a61A7cAeb95b039D031b4E2f55e0e9,
            0x747e42Eb0591547a0ab429B3627816208c734EA7
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch9() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(997778057744658432),
            uint256(1851896407851953553408),
            uint256(18199314924530800),
            uint256(95126570260419424),
            uint256(128072204316935602176)
        ];
        address[5] memory tokens = [
            0x970D50d09F3a656b43E11B0D45241a84e3a6e011,
            0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49,
            0x7aE97042a4A0eB4D1eB370C34BfEC71042a056B7,
            0x88a89866439F4C2830986B79cbe6f69d1Bd548BB,
            0x920Cf626a271321C151D027030D5d08aF699456b
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch10() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(10599020350275274),
            uint256(82145392119721),
            uint256(459199980661675136),
            uint256(2107218757700847140864),
            uint256(81946275431202208)
        ];
        address[5] memory tokens = [
            0x15e770B95Edd73fD96b02EcE0266247D50895E76,
            0x676f784d19c7F1Ac6C6BeaeaaC78B02a73427852,
            0x217D47011b23BB961eB6D93cA9945B7501a5BB11,
            0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb,
            0xc38464250F51123078BBd7eA574E185F6623d037
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch11() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(1961235884980144963584),
            uint256(2017090757584435712),
            uint256(975401970132),
            uint256(19827501440926232),
            uint256(1115065284780084096)
        ];
        address[5] memory tokens = [
            0x484c2D6e3cDd945a8B2DF735e079178C1036578c,
            0x00a35FD824c717879BF370E70AC6868b95870Dfb,
            0xC1c167CC44f7923cd0062c4370Df962f9DDB16f5,
            0x3F56e0c36d275367b8C502090EDF38289b3dEa0d,
            0x9a2e53158e12BC09270Af10C16A466cb2b5D7836
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch12() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(1893827536792218880),
            uint256(61797227864244888),
            uint256(44214791879274208),
            uint256(4392628558934091),
            uint256(1751661131303557791744)
        ];
        address[5] memory tokens = [
            0xdC6fF44d5d932Cbd77B52E5612Ba0529DC6226F1,
            0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC,
            0xfDeFFc7Ad816BF7867C642dF7eBC2CC5554ec265,
            0xB0ae108669CEB86E9E98e8fE9e40d98b867855fD,
            0x3E29D3A9316dAB217754d13b28646B76607c5f04
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch13() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(153225610389268),
            uint256(85497794686834720),
            uint256(251536749221363449856),
            uint256(1043160617794706432),
            uint256(29746368406655604883456)
        ];
        address[5] memory tokens = [
            0xE3AB61371ECc88534C522922a026f2296116C109,
            0x46f21fDa29F1339e0aB543763FF683D399e393eC,
            0x61BAADcF22d2565B0F471b291C475db5555e0b76,
            0xc5b001DC33727F8F26880B184090D3E252470D45,
            0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch14() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(11643860871757961216),
            uint256(4474761024045099),
            uint256(1830318025637219270656),
            uint256(301384262311332020224),
            uint256(999158822594942208)
        ];
        address[5] memory tokens = [
            0x1e925De1c68ef83bD98eE3E130eF14a50309C01B,
            0x74ccbe53F77b08632ce0CB91D3A545bF6B8E0979,
            0x1610e3c85dd44Af31eD7f33a63642012Dca0C5A5,
            0x4E720DD3Ac5CFe1e1fbDE4935f386Bb1C66F4642,
            0xCa0E54b636DB823847B29F506BFFEE743F57729D
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch15() public {
        vm.selectFork(optimismFork);
        uint256[5] memory referenceRates = [
            uint256(1971488595638079979520),
            uint256(3228677542046337536),
            uint256(193699454543614496),
            uint256(936011803995126400),
            uint256(1849944411733104384)
        ];
        address[5] memory tokens = [
            0x6c2f7b6110a37b3B0fbdd811876be368df02E8B0,
            0x28b42698Caf46B4B012CF38b6C75867E0762186D,
            0x2513486f18eeE1498D7b6281f668B955181Dd0D9,
            0x3A18dcC9745eDcD1Ef33ecB93b0b6eBA5671e7Ca,
            0xFdb794692724153d1488CcdBE0C56c252596735F
        ];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }

    function testFork_Integration_GetManyRatesWithConnectors_Batch16() public {
        vm.selectFork(optimismFork);
        uint256[1] memory referenceRates = [uint256(29740079979783895646208)];
        address[1] memory tokens = [0x68f180fcCe6836688e9084f035309E29Bf0A2095];
        IERC20Metadata[] memory concatenated = new IERC20Metadata[](tokens.length + connectors.length + 1);

        for (uint256 i = 0; i < tokens.length; i++) {
            concatenated[i] = IERC20Metadata(tokens[i]);
        }

        for (uint256 j = 0; j < connectors.length; j++) {
            concatenated[tokens.length + j] = IERC20Metadata(connectors[j]);
        }

        concatenated[tokens.length + connectors.length] = IERC20Metadata(USDC);

        uint256[] memory rates = oracle.getManyRatesWithConnectors(uint8(tokens.length), concatenated);
        for (uint256 i = 0; i < tokens.length; i++) {
            assertLe(
                rates[i],
                referenceRates[i] * 102 / 100,
                string.concat(vm.getLabel(tokens[i]), ": returned rate too high")
            );
            assertGe(
                rates[i], referenceRates[i] * 98 / 100, string.concat(vm.getLabel(tokens[i]), ": returned rate too low")
            );
        }
    }
}
