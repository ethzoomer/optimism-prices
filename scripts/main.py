from brownie import accounts, VeloOracle

init_params = {
    "factory": '0x25CbdDb98b35ab1FF77413456B31EC81A6B6B746',
    "initcodeHash": '0xc1ac28b1c4ebe53c0cff67bab5878c4eb68759bb1e9f73977cd266b247d149f0',
}
oracle = VeloOracle.deploy(*list(init_params.values()), {'from': accounts[0]})

# velo -> usdc
a = oracle.getRateWithConnectors(['0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9', '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])

# susd -> usdc
b = oracle.getRateWithConnectors(['0x3c8B650257cFb5f272f799F5e2b4e65093a11a05', '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])

bb = oracle.getRateWithConnectors(['0x4200000000000000000000000000000000000006', '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])

# ldo -> usdc (wsteth + weth as connectors)
c = oracle.getRateWithConnectors(['0xFdb794692724153d1488CcdBE0C56c252596735F', 
                                  '0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb',
                                  '0x4200000000000000000000000000000000000006',
                                  '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])

# red -> usdc (op as connector)
d = oracle.getRateWithConnectors(['0x3417E54A51924C225330f8770514aD5560B9098D', 
                                  '0x4200000000000000000000000000000000000042',
                                  '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])