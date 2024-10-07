from brownie import accounts, VeloOracle, chain

deployer = accounts.load('deployer')

if chain.id == 8453:
    init_params = {
        "factoryV2": '0x420DD381b31aEf6683db6B902084cB0FFECe40Da',
        "CLFactory": '0x5e7BB104d84c7CB9B682AaC2F3d509f5F406809A'
    }
elif chain.id == 10:
    init_params = {
        "factoryV2": '0xF1046053aa5682b4F9a81b5481394DA16BE5FF5a',
        "CLFactory": '0xCc0bDDB707055e04e497aB22a59c2aF4391cd12F'
    } 

oracle = VeloOracle.deploy(*list(init_params.values()), {'from': deployer})
VeloOracle.publish_source(oracle)