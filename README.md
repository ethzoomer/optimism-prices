# Optimism Prices

The Optimism Prices contracts are a lightweight, trustless, and reliable method of pricing tokens on Optimism and Base. 

# Deployments

```
{
    'Optimism': '0xcA97e5653d775cA689BED5D0B4164b7656677011',
    'Base': '0x2DCD9B33F0721000Dc1F8f84B804d4CFA23d7713'
}
```

# Explanation

The current state of token price APIs is not suitable for today's increasingly complex DeFi use cases. Many dapps and services need to be able to quickly and reliably price arbitrary ERC20 tokens, but centralized price APIs don't offer full coverage, frequently failing to price or mispricing illiquid tokens. The Optimism Prices contracts address this. Optimism Prices returns token price data in one smart contract call, and can price any ERC20 against another, while also allowing developers to specify which "hop" assets they want the contract to check to determine the most liquid route from point A to point B.

# Usage

To retrieve the price of tokens denominated in another token, you'll need to call the `getManyRatesWithConnectors` function.
`getManyRatesWithConnnectors` accepts two arguments, `src_len`, an integer representing the number of tokens to price, and `connectors`, an array with the tokens that you want to price at the front, the connector tokens to use as hops in the middle, and the denominator token as the last element. 

If a user wants to price WETH, SNX, LDO, and WBTC in USDC denomination, and they want to check common liquid routes, they would make a call such as `getManyRatesWithConnectors(4, [WETH, SNX, LDO, WBTC, OP, WETH, sUSD, DAI, wstETH, USDC])`. In this case, OP, WETH, sUSD, DAI, and wstETH are being used as connector tokens to check the most liquid routes between the tokens we're trying to price and the denominator token. All of the tokens in the middle of the array should be tokens that you want the contract to check for liquid routes. If you know that there are a few specific assets that your src tokens are often paired against, try adding those tokens in the middle of the array. If you're calling the function for many arbitrary tokens as part of your dapp, we recommend always making calls with common pair tokens in the middle of the `connnectors` array, such as WETH, USDC, and OP.

# To-do

- [x] Get Optimism Prices indexed by Dune to support full price coverage of all tokens in liquidity pools on Optimism and Base *(Now being indexed on both Optimism and Base via automated calling of PriceFetcher.sol's `fetchPrices` function)*
- [x] Allow multiple callers to index prices on PriceFetcher
- [ ] Design incentivization method for PriceFetcher, to ensure historical prices are always being indexed for use by third parties like Dune regardless of potential bot downtime
- [ ] Add TWAP support to allow for Optimism Prices contracts to be used in cases where short term price manipulation of tokens is undesired
