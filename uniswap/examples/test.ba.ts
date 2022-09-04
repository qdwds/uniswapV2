const {
    Fetcher,
    WETH,
    Route,
    Trade,
    TokenAmount,
    TradeType,
    ChainId,
  } = require("quickswap-sdk");
  const ethers = require("ethers");
  // 可以替换为自己的url
  const url = "http://127.0.0.1:8545";
  const customHttpProvider = new ethers.providers.JsonRpcProvider(url);
  
  const chainId = 1337;
  const usdt_address = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
  const aave_address = "0xD6DF932A45C0f255f85145f286eA0b292B21C90B";
  const weth_address = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
  const dai_address = "0x8f3cf7ad23cd3cadbd9735aff958023239c6a063";
  const init = async () => {
    const usdt = await Fetcher.fetchTokenData(
      chainId,
      usdt_address,
      customHttpProvider
    );
    const aave = await Fetcher.fetchTokenData(
      chainId,
      aave_address,
      customHttpProvider
    );
  
    const weth = await Fetcher.fetchTokenData(
      chainId,
      weth_address,
      customHttpProvider
    );
    const dai = await Fetcher.fetchTokenData(
      chainId,
      dai_address,
      customHttpProvider
    );
    // 需要获取protocol的所有token并组合pair ，但是这样效率太低 所以准备几个主流币作为中间转换币应该没什么问题
    const pairs = await Fetcher.fetchPairData(aave, usdt, customHttpProvider);
    const epairs = await Fetcher.fetchPairData(aave, weth, customHttpProvider);
    const epairs2 = await Fetcher.fetchPairData(weth, usdt, customHttpProvider);
    const epairs3 = await Fetcher.fetchPairData(aave, dai, customHttpProvider);
    const epairs4 = await Fetcher.fetchPairData(dai, usdt, customHttpProvider);
    const route = new Route([pairs], aave);
    // const trade = new Trade(
    //   route,
    //   new TokenAmount(aave, "1000000000000000000"),
    //   TradeType.EXACT_INPUT
    // );
    // console.log(route.path);
    console.log("Mid Price aave --> usdt:", route.midPrice.toSignificant(6));
    const amountIn = new TokenAmount(aave, "1000000000000000000");
    const best = Trade.bestTradeExactIn(
      [pairs, epairs3, epairs4, epairs, epairs2],
      amountIn,
      usdt
      // new TokenAmount(usdt, 1000000)
    );
    // 打印最佳路径
    console.log(best[0].route.path);
  };
  
  init();
  