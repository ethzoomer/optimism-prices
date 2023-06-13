from brownie import accounts, VeloOracle

init_params = {
    "factory": '0x25CbdDb98b35ab1FF77413456B31EC81A6B6B746',
    "initcodeHash": '0xc1ac28b1c4ebe53c0cff67bab5878c4eb68759bb1e9f73977cd266b247d149f0',
}

a = accounts.load('0')
oracle = VeloOracle.deploy(*list(init_params.values()), {'from': a},publish_source=True)

# sUSD -> usdc
a = oracle.getRateWithConnectors(['0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9', '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])
a/1e18

# velo -> usdc
b = oracle.getRateWithConnectors(['0x3c8B650257cFb5f272f799F5e2b4e65093a11a05', '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])
b/1e18

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

# optidoge -> usdc (WETH as connector)
e = oracle.getRateWithConnectors(['0x139283255069Ea5deeF6170699AAEF7139526f1f', 
                                  '0x4200000000000000000000000000000000000006',
                                  '0x7F5c764cBc14f9669B88837ca1490cCa17c31607'])


from brownie import accounts, VeloOracle
import json
import time
init_params = {
    "factory": '0x25CbdDb98b35ab1FF77413456B31EC81A6B6B746',
    "initcodeHash": '0xc1ac28b1c4ebe53c0cff67bab5878c4eb68759bb1e9f73977cd266b247d149f0',
}

oracle = VeloOracle.at('0xd688F768769173c8f6FE2f00aA6D2448674508F1')

f = json.load(open('./tokenlist.json'))
lookup = {}
for token in f['tokens']:
    lookup[token['symbol']] = token['address']
# src = ['sETH', 'rETH', 'BIFI', 'LDO', 'wstETH', 'alETH', 'RING', 'fBOMB','opxveVELO', 'UNLOCK', 'RED']
src = ['SPELL']
connectors = ['WETH', 'wstETH', 'VELO', 'OP']
dst = 'USDC' 
in_connectors = src + connectors + [dst]

e = oracle.getManyRatesWithConnectors(len(src),[lookup[sym] for sym in in_connectors])

for token, p in zip(src,e):
    print(token, round(p/1e18, 5))