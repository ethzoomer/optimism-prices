from brownie import accounts, PriceFetcher
from scripts.get_tokens import get_tokens

deployer = accounts.load('deployer')
fetcher = PriceFetcher.at('0xe255e0774416604dd53f75Ea8301157DccE6eB03')

# https://dune.com/queries/2678719
src, _ = get_tokens()
connectors = ['0x9560e827aF36c94D2Ac33a39bCE1Fe78631088Db', '0x4200000000000000000000000000000000000042', '0x4200000000000000000000000000000000000006', '0x9bcef72be871e61ed4fbbc7630889bee758eb81d', '0x2e3d870790dc77a83dd1d18184acc7439a53f475', '0x8c6f28f2f1a3c87f0f938b96d27520d9751ec8d9', '0x1f32b1c2345538c0c6f582fcb022739c4a194ebb', '0xbfd291da8a403daaf7e5e9dc1ec0aceacd4848b9', '0xc3864f98f2a61a7caeb95b039d031b4e2f55e0e9', '0x9485aca5bbbe1667ad97c7fe7c4531a624c8b1ed', '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1', '0x73cb180bf0521828d8849bc8cf2b920918e23032', '0x6806411765af15bddd26f8f544a34cc40cb9838b', '0x6c2f7b6110a37b3b0fbdd811876be368df02e8b0', '0xc5b001dc33727f8f26880b184090d3e252470d45']

dst = '0x7F5c764cBc14f9669B88837ca1490cCa17c31607' # USDC

call_length = 150
for start_i in range(0,len(src),call_length):
  in_connectors = src[start_i:start_i + call_length] + connectors + [dst]
  fetcher.fetchPrices(len(src[start_i:start_i + call_length]), in_connectors , {'from': deployer})