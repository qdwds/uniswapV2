//SPDX-License-Identifier: MIT

pragma solidity =0.6.6;
import "hardhat/console.sol";
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Router01 {
    // 获取 工厂合约地址
    function factory() external pure returns (address);
    // 获取WETH合约地址
    function WETH() external pure returns (address);
    // 添加流动性
    function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    // 添加ETH流动性
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    // 移除流动性
    function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    // 移除ETH流动性
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    //  移除带签名的流动性 带签名后会自动授权
    function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    //  移除带有ETH的流动性
    function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    // 精准tokenA兑换尽量多的TokenB         给输入求输出
    // 输入token1是确认的 求兑换token2的数据
    function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // 使用尽量少的TokenA兑换尽量多的TokenB     给输出求输入
    function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // 精准的ETH兑换尽量多的Token           输入ETh求token
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    // 精准ETH兑换尽量多的token            给输出ETH求输入token数量
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // 精准token兑换尽量多的ETH            给输入token求输出ETH数量
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // 尽量少的ETH对换精准token             给输出token求输出ETH
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    // 计算最优输入量
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    // 输入tokenA返回最多数量的tokenB
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut);
    // 输出tokenA求TokenB的输入数量
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn);
    // 输入tokenA返回最多数量tokenB
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    // 输出tokenB求TokenA的输入数量
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    // 和token有关  设计分红/燃烧调用  交易税（token的交易税）
    // 交易之后 没有做余额检查。 防止交易过 token过少 不会检查数量

    // 移除流动性，支持使用转移代币支付手续费，得到ETH/TOKEN。
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountETH);
    // 移除流动性，同时支持使用链下签名消息授权和使用转移代币支付手续费
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    
    // 支持收税的根据精确的token交换尽量多的token
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    // 支持收税的根据精确的ETH交换尽量多的token
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable;
    // 支持收税的根据精确的token交换尽量多的ETH
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
}



contract UniswapV2Router02 is IUniswapV2Router02 {
    using SafeMath for uint;
    // 工厂合约地址
    address public immutable override factory;
    // WETH合约地址
    address public immutable override WETH;

    // 判定当前区块时间不能超过最晚交易时间
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        _;
    }

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    // 限制只能从WETH合约直接接受ETH，也就是在WETH提取为ETH时。
    // 调用者之传ETH，并未调用函数，未提供信息，receive触发
    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    /**
    * **** ADD LIQUIDITY ****
    * @dev 添加流动性的私有方法,整个方法是在运算。给出A B 的最优数额
    */
    function _addLiquidity(
        address tokenA,         //  tokenA地址
        address tokenB,         //  tokenB地址
        uint amountADesired,    //  期望数量A
        uint amountBDesired,    //  期望数量B
        uint amountAMin,        //  最小数量A
        uint amountBMin         //  最小数量B
    ) internal virtual returns (
        uint amountA,   //  数量A
        uint amountB    //  数量B
    ) {
        // 如果这个交易对不存在，则创建一个交易对
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            // 注意这个tokenA 和 tokenB 肯定是排序过的。
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        // 获取交易对中两个代币的存储量。
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        // 两个交易对的代币储备量都为0 流动性不存在。把所有注入的代币全部转为流动性
        if (reserveA == 0 && reserveB == 0) {
            // 使用用户 自定义的注入量
            (amountA, amountB) = (amountADesired, amountBDesired);
        } 
        // 如果当前配对
        else {
            // 计算 tokenB 最优注入量
            uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
      
            //  如果进来这里说明 这个pair合约的流动性是存在的，那么如果你传的流动性数量比例和当前流动性的比例不一致。就按最少的代币的比例来添加流动性。
            if (amountBOptimal <= amountBDesired) {
                console.log("amountBOptimal", amountBOptimal);
                console.log("amountBMin", amountBMin);
                // 确保B的最优注入量 >= 最小注入量
                require(amountBOptimal >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
                // 返回A/B注入量
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                // 计算A的最优注入量
                uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                // 确保用户Ade 数量足够
                assert(amountAOptimal <= amountADesired);
                // 保证A最优注入量 >= 最小注入量
                require(amountAOptimal >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
                // 返回A/B注入量
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    //  增加流动性，提供的初始资产为TOKEN/TOKEN
    function addLiquidity(
        address tokenA,         //  tokenA地址
        address tokenB,         //  tokenB地址
        uint amountADesired,    //  期望数量A
        uint amountBDesired,    //  期望数量B
        uint amountAMin,        //  最小数量A
        uint amountBMin,        //  最小数量B
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override ensure(deadline) returns (
        uint amountA,   //  数量A
        uint amountB,   //  数量B
        uint liquidity  //  流动性数量
    ) {
        // 先计算出最优A/B注入量。
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        console.log("amountA",amountA);
        console.log("amountB",amountB);
        // 预测tokenA 和 TokenB的合约地址
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        // 将tokenA 和 TokenB 转到交易对中
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        // 调用Pair的 添加流动性方法
        liquidity = IUniswapV2Pair(pair).mint(to);
        console.log("addLiquidity liquidity", liquidity);
    }

    /**
    * @dev 增加流动性，提供的初始资产为ETH/TOKEN。
    把eth转成weth
    */
    function addLiquidityETH(
        address token,              //  token地址
        uint amountTokenDesired,    //  Token期望数量
        uint amountTokenMin,        //  Token最小数量
        uint amountETHMin,          //  ETH最小数量
        address to,                 //  to地址
        uint deadline               //  最后期限
    ) external virtual override payable ensure(deadline) returns (
        uint amountToken,   //  Token数量
        uint amountETH,     //  ETH数量
        uint liquidity      //  流动性数量
    ) {
        // 计算最优量
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        // 预测合约地址
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        console.log("addLiquidityETH pair", pair);
        // 把指定token的value从form转到to地址（交易对）中
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        // 把ETH注入到WETH池子中
        IWETH(WETH).deposit{value: amountETH}();
        // 转账WETH到到 交易对中，并且根据转账的返回值。判断是否转账成功
        assert(IWETH(WETH).transfer(pair, amountETH));
        // 创建流动性，并转入用户地址
        liquidity = IUniswapV2Pair(pair).mint(to);
        

        // refund dust eth, if any
        // 如果还有剩余的ETH则返回剩余的ETH。调用者余额大于最优计算出来的额度的话。
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        console.log("addLiquidityETH liquidity", liquidity);
        console.log("addLiquidityETH msg.value > amountETH", msg.value > amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    /**
     * @dev 移除流动性，得到的最终资产为TOKEN/TOKEN。
     * return 返回 当前流动性代币换回两种代币的数量
     */
    function removeLiquidity(
        address tokenA,    //  tokenA地址
        address tokenB,    //  tokenB地址
        uint liquidity,    //  流动性数量
        uint amountAMin,   //  最小数量A
        uint amountBMin,   //  最小数量B
        address to,        //  to地址 销毁LP后里面的两个代币返回给谁
        uint deadline      //  最后期限
    ) public virtual override ensure(deadline) returns (
        uint amountA,   //  数量A
        uint amountB    //  数量B
    ) {
        // 获取交易对地址 预测合约地址
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        // 把流动性的代币转到 交易对(pair)地址中
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        // 把流动性代币燃烧掉，把两个代币退换给to地址。记录退换的两种代币数量
        (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
        // 排序
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        // 传入的第一个地址 == 排序后的第一个地址。 返回排序后的两个代币数量
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        // 要提取的代币不能小于用户输入的代币数量，否者报错
        require(amountA >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
    }
    /**
     * @dev 移除流动性，得到的最终资产为ETH/TOKEN
     * return  返回 为兑换处的token量 / ETH量
     */
    function removeLiquidityETH(
        address token,      //  token地址
        uint liquidity,     //  流动性数量
        uint amountTokenMin,//  token最小数量
        uint amountETHMin,  //  ETH最小数量
        address to,         //  to地址
        uint deadline       //  最后期限
    ) public virtual override ensure(deadline) returns (
        uint amountToken,  // token数量
        uint amountETH     // ETH数量
    ){
        // 用流动性 兑换处 token 和ETH
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        console.log("removeLiquidityETH amountToken", amountToken);
        console.log("removeLiquidityETH amountETH", amountETH);
        // 兑换出来的token转给to
        TransferHelper.safeTransfer(token, to, amountToken);
        // 把WETH注入WETH池子中，兑换出ETH
        IWETH(WETH).withdraw(amountETH);
        // ETH转给to地址
        TransferHelper.safeTransferETH(to, amountETH);
    }
    /**
     * @dev 移除流动性，支持使用链下签名消息授权，得到TOKEN/TOKEN
     * return 返回两个代币数量
     */
    function removeLiquidityWithPermit(
        address tokenA,    //  tokenA地址
        address tokenB,    //  tokenB地址
        uint liquidity,    //  流动性数量
        uint amountAMin,   //  最小数量A
        uint amountBMin,   //  最小数量B
        address to,        //  to地址
        uint deadline,     //  最后期限
        bool approveMax,   //  全部批准
        uint8 v,           //  v
        bytes32 r,         //  r
        bytes32 s          //  s
    ) external virtual override returns (
        uint amountA,   //  数量A
        uint amountB    //  数量B
    ) {
        // 获取交易对
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        //  value = 批准全部  ?  uint256最大值 : 自定义流动性
        uint value = approveMax ? uint(-1) : liquidity;
        // 签名授权
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        // 移除流动性返回两个代币数量
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        console.log("removeLiquidityWithPermit amountA,", amountA);
        console.log("removeLiquidityWithPermit amountB", amountB);
    }
    /**
     * @dev 移除流动性，支持使用链下签名消息授权，得到ETH/TOKEN
     */
    function removeLiquidityETHWithPermit(
        address token,        //  token地址
        uint liquidity,       //  流动性数量
        uint amountTokenMin,  //  token最小数量
        uint amountETHMin,    //  ETH最小数量
        address to,           //  to地址
        uint deadline,        //  最后期限
        bool approveMax,      //  全部批准
        uint8 v,              //  v
        bytes32 r,            //  r
        bytes32 s             //  s
    ) external virtual override returns (
        uint amountToken,   //  token数量
        uint amountETH      //  ETH数量
    ) {
        // 预测合约地址
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        //  value = 批准全部  ?  uint256最大值 : 自定义流动性
        uint value = approveMax ? uint(-1) : liquidity;
        // 签名
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        // 移除流动性 返回 token 和ETH
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        console.log("removeLiquidityETHWithPermit amountToken", amountToken);
        console.log("removeLiquidityETHWithPermit amountETH", amountETH);
    }

    // 移除流动性时，支持用转账的token支付手续费
    // 移除流动性，支持使用转移代币支付手续费，得到ETH/TOKEN
    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,      //  
        uint liquidity,     //  
        uint amountTokenMin,//  
        uint amountETHMin,  //  
        address to,         //  
        uint deadline       //  
    ) public virtual override ensure(deadline) returns (
        uint amountETH      //  
    ) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        // token 转给调用者
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    // 移除流动性ETH，并支付转账代币的许可证支持费
    // 移除流动性，同时支持使用链下签名消息授权和使用转移代币支付手续费 ETH/TOKEN
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,      //  
        uint liquidity,     //  
        uint amountTokenMin,//  
        uint amountETHMin,  //  
        address to,         //  
        uint deadline,      //  
        bool approveMax,    //  
        uint8 v,            //  
        bytes32 r,          //  
         bytes32 s          //  
    ) external virtual override returns (
        uint amountETH      // 
    ) {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    /**
     * @dev 代币兑换
     */
    function _swap(
        uint[] memory amounts,  //  要求初始金额已经发送到第一对
        address[] memory path,  //  数额数组
        address _to             //  to地址
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            // 读取交易对的两个代币地址
            (address input, address output) = (path[i], path[i + 1]);
            // 获取排序后的第一个token地址
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            // 要兑换的代币量，amounts[ i + 1 ]的第二个代币的数量
            // 当前交易对的买入值，同时也是下一个交易对的卖出值
            uint amountOut = amounts[i + 1];
            // 获取两个代币的数量
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            console.log("uint(0)", uint(0));
            console.log("_swap amount0Out", amount0Out);
            console.log("_swap amount1Out", amount1Out);
            // 递增的i < (path - 2) : 预测合约地址 : 传入的 _to
            // 计算当前交易对的接受地址[a, b] 返回to地址。[a,b,c] 返回[(a,b)排序完的最大值的地址, c]预测出来的合约地址
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            // 预测出来的pair地址调用  调用pair.swap()
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output))
            .swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    /**
     * @dev 根据精确的token交换尽量多的token
     * 给输入求输出
     * 给最少的输入求最多的输出
     */
    function swapExactTokensForTokens(
        uint amountIn,          //  精确输入数额
        uint amountOutMin,      //  最小输出数额
        address[] calldata path,//  路径数组  路径是从前端传过来的
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override ensure(deadline) returns (
        uint[] memory amounts   //数额数组
    ) {
        // 根据输入计算能兑换多少输出代币
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        
        // 这个循环自己写的 查看代币数量
        for (uint256 i = 0; i < amounts.length; i++) {
            console.log("swapExactTokensForTokens amounts", amounts[i]);
        }
        // console.log("swapExactTokensForTokens path", path);
        // 最终兑换token数量应该 大于 用户输入最小数量
        require(amounts[amounts.length - 1] >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        // 把path[0]token 转到 交易对流动性中。
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        // 交换代币
        _swap(amounts, path, to);
    }

    /**
     * @dev 使用尽量少的token交换精确的token
     * 给输出 求输入
     * @dev token0 兑换 token1
     */
    function swapTokensForExactTokens(
        uint amountOut,         //  计算得出输出金额
        uint amountInMax,        // 精准输入金额
        address[] calldata path,//  路径数组
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override ensure(deadline) returns (
        uint[] memory amounts   //  数额数组
    ) {
        // 计算需要多少代币才能对换一定数量的amountOut
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        for (uint256 i = 0; i < amounts.length; i++) {
            console.log("swapExactTokensForTokens amounts", amounts[i]);
        }
        require(amounts[0] <= amountInMax, "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT");
        // console.log("swapTokensForExactTokens path",path);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    /**
     * @dev 根据精确的ETH交换尽量多的token
     输入ETH求输出
     */
    function swapExactETHForTokens(
        uint amountOutMin,      //  最小输出数额
        address[] calldata path,//  路径数组
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override payable ensure(deadline) returns (
        uint[] memory amounts      //  数额数组
    ){
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    /**
     * @dev 使用尽量少的token交换精确的ETH
     给输出ETH 求 输入
     */
    function swapTokensForExactETH(
        uint amountOut,         //  精确输出数额
        uint amountInMax,       //  最大输入数额
        address[] calldata path,//  路径数组
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override ensure(deadline) returns (
        uint[] memory amounts   //  数额数组
    ){
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /**
     * @dev 根据精确的token交换尽量多的ETH
    //  给输入token 输出 ETH
     */
    function swapExactTokensForETH(
        uint amountIn,          //  精确输入数额
        uint amountOutMin,      //  最小输出数额
        address[] calldata path,//  路径数组
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override ensure(deadline) returns (
        uint[] memory amounts   //  数额数组
    ){
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /**
     * @dev 使用尽量少的ETH交换精确的token
     给 输出精确toekn 求输入 ETH
     */
    function swapETHForExactTokens(
        uint amountOut,         //  精确输出数额
        address[] calldata path,//  路径数组
        address to,             //  to地址
        uint deadline           //  最后期限
    ) external virtual override payable ensure(deadline) returns (
        uint[] memory amounts  //  数额数组
    ){
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    // 主要功能就是交换 token0 > token1 > token2
    // 交换的代币数量是根据实际交易的代币数量(有的可能有分红/销毁功能)
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,  // 代币地址
        address _to             // 返回地址
    ) internal virtual {
        // [token0, token1, token2, token3]
        for (uint i; i < path.length - 1; i++) {
            // 获取两个token地址
            (address input, address output) = (path[i], path[i + 1]);
            // 排序
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            // 预测合约地址
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;

            { // scope to avoid stack too deep errors
            // 获取储备量
            (uint reserve0, uint reserve1,) = pair.getReserves();
            // 获取对应的储备量， 将资产和地址对应起来
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            console.log("reserveInput", reserveInput);
            // pair合约中的第一个资产减去储备量中的第一个资产
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            console.log("amountInput", amountInput);
            // 计算最优卖出(输出)数量，
            amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            // 代币地址重小到大排序，这样就能和swap输入保持一致
            // 为什么会是uint(0)？？ 因为在swap交易中只会卖出一种资产买入另一种资产
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            // 获取后续token的pair合约，如果没有就返回传入的地址，完成交易
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            console.log("amount0Out, amount1Out, to",amount0Out, amount1Out, to);
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    // 精准token0兑换token1
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,          // token0输入数量
        uint amountOutMin,      // token1最小输出数量
        address[] calldata path,//  地址
        address to,             // 发送给谁
        uint deadline           // 时间
    ) external virtual override ensure(deadline) {
        // 用户卖出的资产转移到第一个pair交易对中
        // 为什么要先转移到交易对？？ 因为当前交易对中的额度是原来的，必选传入最新的数量更新储备量后在去做后续的交换
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        // 以及to(交易者)地址 在path最后一个地址中的余额，[t1，t2，t3,t4] 记录的t4的余额。
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        // 代币交换
        _swapSupportingFeeOnTransferTokens(path, to);
        // 接受者买入的资产不能小于用户指定的最小值。
        console.log("IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore)", IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore));
        console.log("amountOutMin", amountOutMin);
        // 上一个交易交易完成，所以这里能拿到 接受者在当前合约中的余额
        // 交易得到的数量 要大于 最小值
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }
    // 精准ETH 换token
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,      // 
        address[] calldata path,// 
        address to,             // 
        uint deadline           // 
    ) external virtual override payable ensure(deadline)
    {
        // 最后一项必须是weth地址
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");
        // 获取用户转移了多少eth的数量
        uint amountIn = msg.value;
        // 存款
        IWETH(WETH).deposit{value: amountIn}();
        // 转移weth到pair合约中 失败回退
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        //  查询调用者在最后一个token中的余额数量
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        // swap 交换 token
        _swapSupportingFeeOnTransferTokens(path, to);
        // 交易得到的数量 要大于 最小值
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }
    // 精准token 换 eth
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,          // 
        uint amountOutMin,      // 
        address[] calldata path,// 
        address to,             // 
        uint deadline           // 
    ) external virtual override ensure(deadline)
    {
        // 要转weth 所以最后一项必须是weth的地址
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");
        // 要卖出的token 转给pair地址中。
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        //  swap 交换。 
        _swapSupportingFeeOnTransferTokens(path, address(this));
        // 当前合约中 weth的额度
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        // 输出的数量要 大于 最小值。
        require(amountOut >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        // 取款
        IWETH(WETH).withdraw(amountOut);
        // 转移eth
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    // 求对价
    function quote(
        uint amountA,   // 
        uint reserveA,  // 
        uint reserveB   // 
    ) public pure virtual override returns (
        uint amountB   // 
    ) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    // 从写lib 方法并且对外暴露
    // **** LIBRARY FUNCTIONS ****
    // 求输出
    function getAmountOut(
        uint amountIn,    //   输入的tokenA值
        uint reserveIn,   //   tokenA的流动性
        uint reserveOut   //   tokenB的流动性
    ) public view virtual override returns (
    // ) public pure virtual override returns (
        uint amountOut    //    可以兑换的输出值
    ){
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    // 求输入
    function getAmountIn(
        uint amountOut,   //    输入的tokenB的值
        uint reserveIn,   //    tokenA的流动性
        uint reserveOut   //    tokenB的流动性
    ) public view virtual override returns (
        uint amountIn     //    可以兑换的输入值 
    ){
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,          //  输入值
        address[] memory path   //  计算地址
    ) public view virtual override returns (
        uint[] memory amounts   //  每个兑换的数量
    ){
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,         //
        address[] memory path   //
    ) public view virtual override returns (
        uint[] memory amounts   //
    ){
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        // 5 = 2 + 4 >= 2 === 5 > 2
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        // 3 = 5 - 2 <= 5  === 3 <= 5;
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        // (0 || 6 = 2 * 3 ) / 3 == 2  === 2 == 2;
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    // token排序 （ 小 , 大)
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        // 两个地址不能为空
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        // token排序
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // 地址不能为空，检验最小的就行，因为token0 不为空那么token1绝对不可能是空
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    // 使用create2 预测合约地址。
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        
        pair = address(uint(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                // uniswapV2Factory 的字节码 ( INIT_CODE_PAIR_HASH )
                hex"ca584501cf4ff857c17d9bba6376db9da706e0a2bc267e2f1041add395c36176" // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    // 获取排序后 交易对中恒定乘积的各资产的值，token0 和 token1 两个资产的值。
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        // token 排序
        (address token0,) = sortTokens(tokenA, tokenB);
        // 预测合约地址，并且返回两个代币储备量
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        // token地址排序。 判断传进来的第一个地址是否和排序完的第一个地址是否相等
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    // 按一定比例由一种资产的值计算另一种资产值， 计算最优注入量 
    /**
     * amountA 输入的价格
     * reserveA 储备量
     * reserveB 储备量
     */
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        // amountB = amountA * reserveB / reserveA
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    // 注入token0，返回能最多兑换token1的数量
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal view returns (uint amountOut) {
        // token0的数量必须 > 0
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        // 交易对的储备量要 > 0
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        // 计算收取手续费后的注入量
        //  20 * 997 = 19940
        uint amountInWithFee = amountIn.mul(997);
        console.log("amountInWithFee", amountInWithFee);

        // 分子 = A注入量 * B注入量
        // 1994 * 1000 = 19940000
        uint numerator = amountInWithFee.mul(reserveOut);
        console.log("numerator", numerator);

        //  分母 = A注入量 * 1000 + A注入量
        // 1000 * 1000 + 19940 = 1019940
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        console.log("denominator", denominator);

        //  该公式根据 （A储备量 + A注入量） * （B储备量 - B提出量） = K = A储备量 * B储备量 推得
        // 19940000 / 1019940 = 19.550169617820657
        amountOut = numerator / denominator;
        console.log("amountOut", amountOut);

    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    // 给定一个资产的输出量和对储备金，返回另一个资产所需的输入量
    // 获得买入数量
    // A/B交易对中，买进B资产 计算卖出A资产的数量.
    // 顶顶一个输出 求输入多少
    function getAmountIn(
        uint amountOut,     //  买入数量
        uint reserveIn,     //  储备量0
        uint reserveOut     //  储备量1
    ) internal view returns (
        uint amountIn       //  得到 买入数量
    ) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        // 200 * 1000 * 1000 = 200000000
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        console.log("numerator", numerator);

        // (1000 - 200) * 997 =  797600 扣除手续费
        uint denominator = reserveOut.sub(amountOut).mul(997);
        console.log("denominator", denominator);

        // 200000000 / 797600 + 250.75225677031094 + 1  == 251
        amountIn = (numerator / denominator).add(1);
        console.log("amountIn", amountIn);
    }

    // performs chained getAmountOut calculations on any number of pairs
    // 计算`能兑换多少`代币
    // 计算能对兑换多少代币，可以计算兑换数量的交易对
    // 计算token0能兑换多少token1代币
    // 获取卖出数量
    // A/B交易对的，卖出A资产计算买进B资产的数量。卖出的资产会扣千分之三手续费
    // 通过多个交易对来兑换 
    // [A, B, C, D]     A|B => B|C => C|D ，获得 输指定A能得到多少D
    function getAmountsOut(
        address factory,        //  工厂
        uint amountIn,          //  注入资产数量
        address[] memory path   //  代币兑换路径 
    ) internal view returns (
        uint[] memory amounts   //  返回记录数量的数组，记录中间兑换和最终兑换的token数量
    ) {
        // 确保兑换路径 > 2， 否者没必要调用兑换函数
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        // 返回一个与 路径长度一致的数组。记录每个token的代币数量
        amounts = new uint[](path.length);
        // token0的注入量
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            // 获取交易对的储备量
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            // path 里面存储的是 token 地址
            // 记录上一个token兑换下一个token的代币数量，以此性循环
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
            // console.log(amounts[i + 1]);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    // 计算`需要提交多少`代币
    // 计算需要提交多少token0代币，才能兑换指定的token1代币
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            console.log("getAmountsIn path[i - 1], path[i]", path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes("approve(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        // abi.decode(data, (bool)  解码data 为bool类型。存在就是true 不存在就是false
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes("transfer(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        console.log("TransferHelper success",success);
        console.log("TransferHelper abi.decode(data, (bool)", abi.decode(data, (bool)));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }
    
    //  把指定token的value从form转到to地址(可以是交易对)中。
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    // 把ETH转给指定地址
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}