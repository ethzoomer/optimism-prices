from brownie import accounts, VeloOracle, chain
from scripts.get_tokens import get_tokens_base, get_tokens_op
import json

if chain.id == 10:
    src, symbols = get_tokens_op()
    data = json.load(open('./config.json'))['velo']
    oracle = VeloOracle.at('0x6a3af44e23395d2470f7c81331add6ede8597306')
elif chain.id == 8453:
    src, symbols = get_tokens_base()
    data = json.load(open('./config.json'))['aero']
    oracle = VeloOracle.at('0xCbF5b6abF55Fb87271338097FDd03E9d82a9d63f')

connectors = data['connectors']
dst = data['dst']

results = []
call_length = 150
for start_i in range(0,len(src),call_length):
  in_connectors = src[start_i:start_i + call_length] + connectors + [dst]
  results.extend(oracle.getManyRatesWithConnectors(len(src[start_i:start_i + call_length]), in_connectors))

# for i,res in enumerate(results):
#    if res == 0:
#       print(symbols[i])

for sym, price in zip(symbols, results):
   print(sym, price/1e18)
