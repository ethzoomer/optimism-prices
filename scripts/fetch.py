from brownie import accounts, PriceFetcher, chain
from scripts.get_tokens import get_tokens_base, get_tokens_op
from brownie.network import priority_fee, max_fee

priority_fee("0.0003 gwei")

deployer = accounts.load('deployer')
if chain.id == 10:
  fetcher = PriceFetcher.at('0xe255e0774416604dd53f75Ea8301157DccE6eB03')
  src, _ = get_tokens_op()
  connectors = ['0x9560e827aF36c94D2Ac33a39bCE1Fe78631088Db', '0x4200000000000000000000000000000000000042', '0x4200000000000000000000000000000000000006', '0x9bcef72be871e61ed4fbbc7630889bee758eb81d', '0x2e3d870790dc77a83dd1d18184acc7439a53f475', '0x8c6f28f2f1a3c87f0f938b96d27520d9751ec8d9', '0x1f32b1c2345538c0c6f582fcb022739c4a194ebb', '0xbfd291da8a403daaf7e5e9dc1ec0aceacd4848b9', '0xc3864f98f2a61a7caeb95b039d031b4e2f55e0e9', '0x9485aca5bbbe1667ad97c7fe7c4531a624c8b1ed', '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1', '0x73cb180bf0521828d8849bc8cf2b920918e23032', '0x6806411765af15bddd26f8f544a34cc40cb9838b', '0x6c2f7b6110a37b3b0fbdd811876be368df02e8b0', '0xc5b001dc33727f8f26880b184090d3e252470d45']
  dst = '0x7F5c764cBc14f9669B88837ca1490cCa17c31607' # USDC
else:
  fetcher = PriceFetcher.at('0x593D092BB28CCEfe33bFdD3d9457e77Bd3084271')
  src, _ = get_tokens_base()
  connectors = ['0x940181a94A35A4569E4529A3CDfB74e38FD98631', '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb', '0x4621b7a9c75199271f773ebd9a499dbd165c3191', '0x4200000000000000000000000000000000000006', '0xb79dd08ea68a908a97220c76d19a6aa9cbde4376', '0xf7a0dd3317535ec4f4d29adf9d620b3d8d5d5069']
  dst = '0xd9aaec86b65d86f6a7b5b1b0c42ffa531710b6ca' # USDbC

call_length = 150
for start_i in range(0,len(src),call_length):
  in_connectors = src[start_i:start_i + call_length] + connectors + [dst]
  fetcher.fetchPrices(len(src[start_i:start_i + call_length]), in_connectors , {'from': deployer})