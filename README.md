# Optimism Prices

The Optimism Prices contracts are a lightweight, trustless, and reliable method of pricing tokens on Optimism. 

# Explanation

The current state of token price APIs is not suitable for today's increasingly complex DeFi use cases. Many dapps and services need to be able to quickly and reliably price arbitrary ERC20 tokens, but centralized price APIs don't offer full coverage, frequently failing to price or mispricing illiquid tokens. The Optimism Prices contracts address this. Optimism Prices returns token price data in one smart contract call, and can price any ERC20 against another, while also allowing developers to specify which "hop" assets they want the contract to check to determine the most liquid route from point A to point B.

# Usage

Optimism Prices is currently deployed at `0xd688F768769173c8f6FE2f00aA6D2448674508F1`. 

To retrieve the price of tokens `A`, `B`, `C`, etc denominated in token `D`, you'll need to call the `getManyRatesWithConnectors` function.
`getManyRatesWithConnnectors` accepts two arguments, an integer representing the number of tokens you wish to retrieve the prices of, and an array of `connector` tokens. 

The `connector` array argument should consist of the tokens that you wish to find the prices of at the front of the array, any tokens that you wish to use in your routing path when fetching prices, and finally the token that you want to denominate in (frequently USDC or another stablecoin).

If you're calling the function for many arbitrary tokens as part of your dapp, we recommend making your call with common pair tokens in the middle of the `connectors` array, such as WETH, USDC, and OP. In the below example, we want to find the prices of OP, WBTC, OPTIDOGE, FXS, and LUSD. We make the first argument 5, indicating that the 5 tokens at the beginning of the `connectors` array are the ones we want to find the prices for. Then we include WETH, OP, VELO, SUSD, and FRAX as tokens to check when routing (note that we can still include OP in here despite OP also being one of the tokens that we are fetching the price for!), and finally we make USDC the last token in the array because this is what we wish to denominate in.

The returned results are all always represented with 18 decimal places, regardless of the decimals of the token that you are fetching prices for or are denominating in.

`getManyRatesWithConnectors` allows you to fetch the prices of 100+ tokens, with 30+ routing tokens, in a single RPC call!

![Example](https://i.ibb.co/r0RF8rF/Screenshot-2023-02-04-at-11-22-42-PM.png)

# To-do

- Get Optimism Prices indexed by Dune to support full price coverage of all tokens in liquidity pools on Optimism
- Add TWAP support to allow for Optimism Prices contracts to be used in cases where short term price manipulation of tokens is undesired
