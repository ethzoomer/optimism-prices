from dune_client.client import DuneClient
from brownie import chain, VeloOracle, accounts

deployer = accounts.load('deployer')
dune = DuneClient.from_env()

if chain.id == 10:
    pools = dune.get_latest_result(3991187)
    oracle = VeloOracle.at('0x6a3af44e23395d2470f7c81331add6ede8597306')
elif chain.id == 8453:
    pools = dune.get_latest_result(3989470)
    oracle = VeloOracle.at('0xCbF5b6abF55Fb87271338097FDd03E9d82a9d63f')

pairs = [[item['token0'], item['token1'], item['tickSpacing'] ] for item in pools.get_rows()]
oracle.enableCLPairs(pairs, {'from':deployer})

