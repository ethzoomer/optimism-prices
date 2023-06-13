from brownie import accounts, VeloOracle
import json

init_params = {
    "factoryV1": '0x25CbdDb98b35ab1FF77413456B31EC81A6B6B746',
    "factoryV2": '0x79bca9bcc19e157cb5f8c5a2f4d6cb951b1f8dce',
    "initcodeHash": '0xc1ac28b1c4ebe53c0cff67bab5878c4eb68759bb1e9f73977cd266b247d149f0',
}

oracle = VeloOracle.deploy(*list(init_params.values()), {'from': accounts[0]})

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