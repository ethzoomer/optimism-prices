# Optimism Prices

The Optimism Prices contracts are a lightweight, trustless, and reliable method of pricing tokens on Optimism. 

# Explanation

The current state of token price APIs is not suitable for today's increasingly complex DeFi use cases. Many dapps and services need to be able to quickly and reliably price arbitrary ERC20 tokens, but centralized price APIs don't offer full coverage, frequently failing to price or mispricing illiquid tokens. The Optimism Prices contracts address this. Optimism Prices returns token price data in one smart contract call, and can price any ERC20 against another, while also allowing developers to specify which "hop" assets they want the contract to check to determine the most liquid route from point A to point B.

# Usage

Optimism Prices is currently deployed at `0xE50621a0527A43534D565B67D64be7C79807F269`. 

To retrieve the price of a token `A` denominated in token `B`, you'll need to call the `getRateWithConnectors` function.
`getRateWithConnnectors` accepts one argument, an array of `connector` tokens. 

The first token in the array should be token `A`, the token that you want to find the price of, and the last token in the array should be token `B`, the token that you want to denominate in (frequently USDC or another stablecoin for most use cases). All of the tokens in the middle of the array should be tokens that you want the contract to check for liquid routes. If you know that there are a few specific assets that your token `A` is often paired against, try adding those tokens in the middle of the array. If you're calling the function for many arbitrary tokens as part of your dapp, we recommend always making calls with common pair tokens in the middle of the `connnectors` array, such as WETH, USDC, and OP. Below is an example of a `getRateWithConnnectors` call to retrieve the price of LDO denominated in USDC, checking wstETH and WETH when routing.

![Example](https://i.ibb.co/gyH1xZk/lidoprice.png)

# To-do

- Get Optimism Prices indexed by Dune to support full price coverage of all tokens in liquidity pools on Optimism
- Add TWAP support to allow for Optimism Prices contracts to be used in cases where short term price manipulation of tokens is undesired
