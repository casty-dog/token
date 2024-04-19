import "dotenv/config"
import { ethers } from "hardhat"
import Artifact from "../artifacts/contracts/CastyToken.sol/CastyToken.json"
import * as fs from "fs"

const main = async () => {
  const privateKey: string = process.env.OWNER_PRIVATE_KEY ?? ""
  if (privateKey === "") throw new Error("OWNER_PRIVATE_KEY is not set")

  // 環境変数チェック
  const rpcUrl: string = process.env.RPC_URL ?? ""
  if (rpcUrl === "") throw new Error("RPC_URL is not set")

  const provider = new ethers.providers.JsonRpcProvider(rpcUrl)
  const signer = new ethers.Wallet(privateKey, provider)
  const factory = new ethers.ContractFactory(Artifact.abi, Artifact.bytecode, signer)

  console.log("provider: ", provider, "signer: ", signer, "factory: ", factory)
  console.log("deploying...")

  // deploy
  const contract = await factory.deploy()
  const txURL = `${process.env.SCAN_BASE_URL}/tx/${contract.deployTransaction.hash}`
  console.log(`deployed to: ${contract.address}`)
  console.log(`deployed by: ${txURL}`)
  await contract.deployed()
  console.log("deployed")
  writeParams(process.env.NETWORK_NAME ?? "", contract.address, txURL)
}

const writeParams = (network_name: string, contract_address: string, tx?: string) => {
  const stream1 = fs.createWriteStream("./tmp/network_name")
  stream1.write(network_name)
  stream1.end()

  const stream2 = fs.createWriteStream("./tmp/contract_address")
  stream2.write(contract_address)
  stream2.end()

  if (tx) {
    const stream3 = fs.createWriteStream("./tmp/tx_url")
    stream3.write(tx)
    stream3.end()
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
