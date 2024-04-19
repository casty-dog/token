import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "dotenv/config"

const config: HardhatUserConfig = {
  networks: {
    base_sepolia: {
      chainId: 84532,
      url: process.env.RPC_URL,
    },
    degen: {
      chainId: 666666666,
      url: process.env.RPC_URL,
    },
  },
  etherscan: {
    apiKey: {
      base_sepolia: process.env.SCAN_API_KEY ?? "",
      degen: process.env.SCAN_API_KEY ?? "",
    },
    customChains: [
      {
        network: "base_sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api" ?? "",
          browserURL: "https://sepolia.basescan.org" ?? "",
        },
      },
      {
        network: "degen",
        chainId: 666666666,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api" ?? "",
          browserURL: "https://sepolia.basescan.org" ?? "",
        },
      },
    ],
  },
  solidity: {
    version: "0.8.24",
    settings: {
      viaIR: true, // prevent Stack too deep error. see: https://docs.soliditylang.org/en/latest/ir-breaking-changes.html
      optimizer: {
        enabled: true, // prevent contract size limit exceeded (Spurious Dragon)
        runs: 200,
      },
    },
  },
  mocha: {
    timeout: 60000,
  },
}

export default config
