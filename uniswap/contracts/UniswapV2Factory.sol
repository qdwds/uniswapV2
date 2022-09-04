//SPDX-License-Identifier: MIT
pragma solidity =0.5.16;
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

interface IUniswapV2ERC20 {
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

// 有些第三方合约希望接受到代码后进行其他操作，好比异步执行回掉函数。
// 主要用于闪电贷
interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// 流动性代币合约
contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    string public constant name = "Uniswap V2";
    string public constant symbol = "UNI-V2";
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    // 用来在不同Dapp之间区分相同结构和内容的签名消息，该值也有助于用户辨识哪些为信任的Dapp
    bytes32 public DOMAIN_SEPARATOR;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // 这一行代码根据事先约定使用permit函数的部分定义计算哈希值，重建消息签名时使用
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    // 用来记录链下签名消息的数量，防止重放攻击
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
        // eip712 授权 自动授权
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                // 用来消除歧义的salt，DOMAIN_SEPARATOR的最后措施。没太看懂。
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)), //  签名名称
                keccak256(bytes("1")),  //  版本
                chainId,                //  当前链的ID
                address(this)           //  验证合约的地址
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // 代币授权转移，主要由第三方合约调用
    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    // 使用线下签名授权
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, "UniswapV2: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        // 校验
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "UniswapV2: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}

// 配对合约
// 交易对的资金池
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath  for uint;
    // 为什么用uint224，因为solidity中没有非整数类型。但是token的数量肯定回有小数。shiyong UQ112*112去模拟浮点类型。
    using UQ112x112 for uint224;

    // 最小流动性 最小1000，用来提供初始流动性时候燃烧掉。
    uint public constant MINIMUM_LIQUIDITY = 10**3;
    // transfor bytecode 使用使用call调用token的transfer方法
    // 用于：使用低级call函数 代替正常函数执行transfer方法。
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    // 工厂地址。因为pair合约是通过工厂合约进行部署，所以需要有一个存放工厂合约的地址
    address public factory; //  工=工厂合约地址
    address public token0;  //  token0地址
    address public token1;  //  token1地址
    
    // 但前pair合约所持有的token数量。
    // 最新的恒定乘积( k = x * y )中两种资产的数量和交易时的区块（创建）时间
    // reserve0 + reserve1 + blockTimestampLast == uint的位数
    // 储备池，token0 和 token1 的余额
    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    // 用于判断是不是区块的第一笔交易。
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    // 记录交易对中两种价格的累积值
    // 用于unistap v2 所提供的价格预言机上。该数值会在每个区块的第一笔交易进行更新。
    uint public price0CumulativeLast;
    uint public price1CumulativeLast;

    // 记录某一时刻恒定乘积中的值，用于开发团队的手续费计算
    // reserve0 * reserve1, 最近一次流动性事件发生后立即生效
    // 这个变量在没有开启收费模式的时候，等于0.只有开启平台收费的时候，这个值才等于k值，因为一般平台开启收费开，k就不会等于两个存储量相乘的结果。
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    // 锁定变量，防止重、重入攻击。
    uint private unlocked = 1;
    // 一个锁，只有unlocked == 1的时候才能调用。
    // 第一个调用者进入后，会将unlocked = 0，第二个调用者无法进入
    // 执行完后将 unlocked = 1；重新将锁打开
    modifier lock() {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    // 获取token0和token1的储备量。和上一个区块的时间戳
    // 获取当前交易对的资产信息及最后交易的区块时间
    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
        console.log("_reserve0", _reserve0 );
        console.log("_reserve1", _reserve1);
        console.log("_blockTimestampLast", _blockTimestampLast);
        console.log("getReserves",_reserve0 + _reserve1 + _blockTimestampLast);
    }

    /*
    * @dev 私有安全发送
    * @param token token地址
    * @param to to地址
    * @param value 数额
    */
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        // 首先必须调用成功，然后无返回值或者返回值为true
        console.log("success", success);
        // console.log("data", data);
        console.log("data.length", data.length);
        console.log("abi.decode(data, (bool))", abi.decode(data, (bool)));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "UniswapV2: TRANSFER_FAILED");
    }

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
    // 同步事件
    event Sync(uint112 reserve0, uint112 reserve1);
    
    constructor() public {
        factory = msg.sender;
    }

    //  在部署时由工厂调用一次
    //  在UNiswapV2Factory.sol中的 createPair 方法中调用 初始化两个token默认值。
    function initialize(address _token0, address _token1) external {
        // 确认工厂合约地址
        require(msg.sender == factory, "UniswapV2: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // 更新计算累计价格
    /*
    * @dev 更新储备量，并在每一个区块的第一次调用时，更新价格累加器
    * @param balance0 余额0
    * @param balance1 余额1
    * @param _reserve0 储备量0
    * @param _reserve1 储备量1
    * update reserves and, on the first call per block, price accumulators
    */
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        // 确认余额0和余额1 小于 uint112的最大值
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), "UniswapV2: OVERFLOW");
        // 区块链时间戳，将时间戳转为uint32
        // 上面判断了token不能大于112，所以  256 - 112 -112  = 34。还用剩余的34位中的32位存储当区块链前时间
        // 时间戳转位32位
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        console.log("block.timestamp", block.timestamp);
        console.log("block.timestamp % 2**32", block.timestamp % 2**32);
        console.log("blockTimestamp", blockTimestamp);

        // 计算时间流逝
        // 如果是同一个区块那么 timeElapsed 就会是 0
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // 112 + 112 + 32 = 256
        // 计算时间加权的累计价格，256中，前112位存储整数，后112存储小数，多的32位存储溢出值
        // 如果时间流逝 > 0，并且储备量0和储备量1 !== 0，也就是第一个调用
        // 如果是在同一个区块的第二笔交易（timeElapsed时间戳相差就是==0 ） 那么就不需要计算价格累计值。如果不是同一个区块就需要计算一下更新储备值
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            // 价格0最后累计 += 储备量1 * 2 ** 112 / 储备量0 * 时间流逝
            // 计算价格累计值
            // 得到224位 _reserve0 然后去除 _reserve1 
            console.log("uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0))",uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)));
            console.log("uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed", uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed);
            console.log("timeElapsed", timeElapsed);
            // UQ112 其实 224位  256 = 224 * 32。使用32最大值 * 224 最大值  < 256 最大值。所以这个地方不会发生溢出。
            // 交易对中两种价格的累计值
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
            console.log("price0CumulativeLast", price0CumulativeLast);
            console.log("price1CumulativeLast", price1CumulativeLast);
        }

        // 更新两个代币数量
        // 余额0和余额1 放入 储备量0和储备量1 中
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        // 更新最后时间戳
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    // 计算手续费
    // 如果收费，则铸币流动性相当于 sqrt(k) 增长的 1/6
    // 每笔交易有千分之三的手续费，k值也会随着缓慢增加，所有连续两个字段之间k值的差值就是这段时间的手续费。
    /*
    * @dev 如果收费，铸造流动性相当于1/6的增长sqrt(k)
    * @param _reserve0 储备量0
    * @param _reserve1 储备量1
    * @return feeOn
    * 这一部分可参考白皮书协议费用那部分·
    * if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    */
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        // 查询工厂合约的feeTo变量值
        address feeTo = IUniswapV2Factory(factory).feeTo();
        console.log("_mintFee 滑点", feeTo);
        // 如果feeTo != 0地址吗，feeOn等于 true 否则 false
        // feeOn = teeTo != address(0) ? treu :false;
        feeOn = feeTo != address(0);
        console.log("_mintFee feeOn",feeOn);
        // 定义k值
        uint _kLast = kLast; // gas savings
        // 如果feeOn等于true
        if (feeOn) {
            // k 不等于 0
            if (_kLast != 0) {
                // 计算（_reserve0*_reserve1）的平方根
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                // 计算k值的平方根
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    // 分子 = erc20总量 * (rootK - rootKlast)
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    // 分母 = rootK * 5 + rootKLast
                    uint denominator = rootK.mul(5).add(rootKLast);
                    // 流动性 = 分子 / 分母
                    uint liquidity = numerator / denominator;
                    // 流动性 > 0 将流动性铸造给feeTo地址 UniswapV2ERC20的_mint 方法
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    //  作用：用户在添加流动性时候，增发ERC20的LP代币给提供者
    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        // 获取两个token的最新数据
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        // 两个token在工厂合约中的余额, 注入资产的余额(两个交易对的余额比如 token0 == btc token1 == usdt),这里就是获取这两token在这合约中的余额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        // 计算当前余额和 上次缓存中的 差值
        // amount0 = 余额0 - 储备0
        uint amount0 = balance0.sub(_reserve0);
        // amount1 = 余额1 - 储备1
        uint amount1 = balance1.sub(_reserve1);
        // 返回铸造费开关 开发团队的铸造手续费开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        console.log("feeOn", feeOn);
        // 已经发行的流动性的总量
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        // 如果是新发行的总量是0
        if (_totalSupply == 0) {
            // 第一次铸币（第一次添加流动信），值为 根号k - MINIMUM_LIQUIDITY（最小流动性）
            // 流动性 = (数量0 * 数量1)的平方根 - 最小流动性1000
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            console.log("main liquidity", liquidity);
            // 把 MINIMUM_LIQUIDITY 赋值给地址0，永久锁住
            // 在总量为0的初始状态，永久锁定最低流动性
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            // 计算增量的token占总池子的比例，作为新币的数量。
            // 流动性 = 最小值(amount0 * _totalSupply - _reserve0 和 (amount1 * _totalSupply) / reserve1)
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        // 流动性必须大于0，否者相当于 没有增发流动性
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        // 铸造流动性给to地址，增加流动性这个人的地址。
        _mint(to, liquidity);
        //  更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        // 如果有铸造费 ； k = 储备0 * 储备1
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // 燃烧代币销毁/减少流动性
    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        console.log("burn _reserve0 _reserve1",_reserve0, _reserve1);

        // 获取token0和token1两个代币储备量 => 节省gas
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings

        // 获取当前合约中token0和otken1的余额
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));

        // 从当前和合约的balanceOf映射中获取当前合约自身流动性数量
        // 当前合约的余额是用户通过合约发送到pair合约要销毁的金额
        uint liquidity = balanceOf[address(this)];

        // 铸造费开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        // 已经发行的流动性的总量
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        // amount0和amount1是用户能取出来多少的数额
        // amount0 = 流动性数量 * 余额0 / totalSuopply 使用余额确保比例分配
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        
        // 两个可取出来的余额必须大于0
        require(amount0 > 0 && amount1 > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED");
        
        // 销毁当前流动性
        _burn(address(this), liquidity);
        // 将amount0数量的token0返回给to地址
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        // 更新两个token的余额
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }
    /*
    * @dev 交换方法
    * @param amount0Out 买入token0的的额度
    * @param amount1Out 买入token1的的额度
    * @param to to地址
    * @param data 用于回调的数据
    * @notice 应该从执行重要安全检查的合同中调用此低级功能
    * this low-level function should be called from a contract which performs important safety checks
    */
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        // 交换的数值需大于0
        require(amount0Out > 0 || amount1Out > 0, "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT");
        // 获取储备量token0和token1在当前合约中的储备量
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        // 买入token数量 必须要小于储备量中的数量
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "UniswapV2: INSUFFICIENT_LIQUIDITY");

        // 记录当前合约中剩余token的数量
        uint balance0;
        uint balance1;
        // 转移代币
        {
            // scope for _token{0,1}, avoids stack too deep errors
            // 标记_token{ 0, 1 }的作用域，避免堆栈太深，EVM中多只有16个栈
            // 使用临时变量存储两个token的地址。节省gas
            address _token0 = token0;
            address _token1 = token1;
            // 确保token0和token1 !== to
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            //  发送token0代币,从token0转出？
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            // 如果data长度大于0，调用to地址的接口
            // 闪电贷   买入资产之后 卖出资产之前
            if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
            // 获取token0和token1在当前合约中剩余的余额，赋值给上面定义的变量
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
            console.log("swap balance0",balance0);
            console.log("swap balance1",balance1);
        }
        /**
            if(剩余余额 > 当前储备0 - 转移走的额度){
                return 剩余余额 - （ 当前储备量0 - 转移走的额度 ）
            }else{
                return 0 
            }
         */
        // 计算实际转移进来的代币数量
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        
        // 确认 输入 (amount0In || amount1In)  > 0
        // 计算转入的两个token数量必须大于0 才能交易成另一种资产
        require(amount0In > 0 || amount1In > 0, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT");
        // 恒定乘积计算
        { 
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            // 调整后的余额 =  剩余余额 * 1000 - (amount0In * 3)
            // 扣除千分之三的手续费
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            // 确认调整后余额0 * 调整后余额1 >= 储备0 * 储备1 * 1000000
            console.log("balance0Adjusted.mul(balance1Adjusted)", balance0Adjusted.mul(balance1Adjusted));
            console.log("uint(_reserve0).mul(_reserve1).mul(1000**2)", uint(_reserve0).mul(_reserve1).mul(1000**2));
            // 剩余的储备量 要大于 之前剩余的储备量
            // 新的恒定乘积的积必须大于旧的值
            // 疑问：交易的只是两个代币交换，为什么必须新的大于旧的呢？
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), "UniswapV2: K");
        }
        // 更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    

    /*
    * @dev 强制平衡以匹配储备，按照储备量匹配余额
    * 强制让余额 == 储备量。一搬用于出本了溢出的情况下，将多余的余额转给`address(to`上，使余额等于储备量
    * 强制让交易对合约中的两种代币的实际余额和报错的恒定乘积中的资产保持一致。多余的发送给调用者
    * 注意： 任何人都能调用该函数获取额外的资产。前提是两个代币中存在多余的资产
    * @param to to地址 
    */
    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        console.log("IERC20(_token0).balanceOf(address(this)).sub(reserve0)", IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        console.log("IERC20(_token1).balanceOf(address(this)).sub(reserve1)", IERC20(_token1).balanceOf(address(this)).sub(reserve1));
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    

    /*
    * @dev 强制恒定乘积中的资产 == 两种代币的实际余额。通常情况下是相等的。
    */
    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

// 工厂合约
contract UniswapV2Factory is IUniswapV2Factory {
    // 平台费收取的地址 如何没有设置手续费收款地址那个就是 000000
    address public feeTo;
    // 可以设置平台费收取地址的地址
    address public feeToSetter;
    // 记录所有交易对地址
    mapping(address => mapping(address => address)) public getPair;
    // {
    //     address:{
    //         address:address
    //     }
    // }
    // 记录所有交易对地址  用数组可以遍历
    address[] public allPairs;
    // 交易对被创建时候触发
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    // 读取initCode UniswapV2Router中使用
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));

    constructor(address _feeToSetter) public {
        //  手续费设置员 能够设置手续费的收取地址
        feeToSetter = _feeToSetter;
    }

    // 返回所有交易地址对的长度
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }


    // 创建一组新的交易对，传入的参数是两个token的address。
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        // 确保两个合约地址不是相等
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        // 排序 因为需要用这两个地址做 盐
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // 确保地址不能为空，为什么只校验0呢？因为token1比token0大。0如果不为空那么1就不会为空
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        // 确保映确保当前交易对不存在
        require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS"); // single check is sufficient
        // 初始化 UniswapV2Pair 的字节码变量，得到 bytecode合约经过编译之后的16进制源码
        // creationCode主要用来在内嵌汇编中自定义合约创建流程
        // bytecode为内存中创建的字节码的字节数组，他是引用类型。所以在调用bytecode时候会直接通过地址查找。
        // creationCode实际内容的起始位置是add(creationCode, 32) 32是什么？因为bytecode开始的第32位是creationCode的长度，从32位开始才是creationCode内容
        // add(bytecode, 32) 其实对应的就是 mload(bytecode) 获取长度
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        // console.log("create Pair bytecode bottom");
        // console.log(bytecode);
        // 把排序后的token0和token1打成hash, 用作create2 的 随机盐
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // console.log(salt);
        // console.log(bytes1(0xff));
        assembly {
            // 通过create2 预测合约地址
            // create2(v, p, n, s)
            // v => 发送到新合约的ETH 数量 wei 为 单位
            // p => 代码的起始内存地址 
            // n => 代码长度;;;  mload(bytecode) 获取字节码长度的方法
            // s => 盐 唯一值
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        console.log(token0);
        console.log(token1);
        console.log('pair',pair);
    
        // 调用创建一个交易对的初始化方法，将排序后的地址传递过去，因为使用create2函数 创建合约时无法提供构造参数
        IUniswapV2Pair(pair).initialize(token0, token1);
        // 记录预测出来要创建的合约对地址，因为用户在查询的时候并没有排序，所以需要两个都记录上。
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        console.log("pair address", pair);
        // 便于合约外部索引和遍历
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }
    // 设置平台手续费收取地址
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }
    // 设置平台手续费权限控制人
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112
// UQ112x112的库去模拟浮点数类型
library UQ112x112 {
    // uint112 最大值
    uint224 constant Q112 = 2**112;

    // UQ112x112 == uint224

    // encode a uint112 as a UQ112x112
    // 将传入值 相乘 后转为224位
    // 传入值最大只能是uint112，否者返回就会超过uint224
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    //  传入的值(y) 转为224位后。被x 相除。然后返回等到后的uint224位的z值
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}