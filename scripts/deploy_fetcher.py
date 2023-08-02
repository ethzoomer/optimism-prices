from brownie import accounts, PriceFetcher

deployer = accounts.load('deployer')
fetcher = PriceFetcher.deploy('0x07F544813E9Fb63D57a92f28FbD3FF0f7136F5cE', {'from': deployer})
PriceFetcher.publish_source(fetcher)