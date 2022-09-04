import type { NetworksUserConfig } from "hardhat/types/config";

const ACCOUNT_PRIVATE_KEY: string =  process.env.ACCOUNT_PRIVATE_KEY!;
const INFURA_KEY: string  = process.env.INFURA_KEY!;

export const networks: NetworksUserConfig = {
    localhost: {
        url: "http://127.0.0.1:8545/",
        chainId: 31337,
        accounts: [process.env.HARDHAT_PRIVATE_KEY!],
    },
    ganache: {
        url: "HTTP://127.0.0.1:7545",
        chainId: 1337,
        accounts:  [process.env.GANACHE_PRIVATE_KEY!],
    },
    ropsten: {
        url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
        chainId: 3,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    rinkeby: {
        url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
        chainId: 4,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    oke: {
        url: "https://exchaintestrpc.okex.org",
        chainId: 65,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    bsc: {
        url: "https://data-seed-prebsc-2-s2.binance.org:8545/",
        chainId: 97,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    heco: {
        url: "https://http-testnet.hecochain.com",
        chainId: 256,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    matic: {
        url: "https://matic-mumbai.chainstacklabs.com",
        chainId: 80001,
        accounts: [ACCOUNT_PRIVATE_KEY]
    },
    kintsugi: {
        url: "https://kintsugi.themerge.dev/",
        chainId: 1337702,
        accounts: [ACCOUNT_PRIVATE_KEY]
    }
}