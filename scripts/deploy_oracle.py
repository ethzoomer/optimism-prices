from brownie import accounts, VeloOracle

deployer = accounts.load('deployer')

init_params = {
    "factoryV2": '0xF1046053aa5682b4F9a81b5481394DA16BE5FF5a'
}

oracle = VeloOracle.deploy(*list(init_params.values()), {'from': deployer})
VeloOracle.publish_source(oracle)