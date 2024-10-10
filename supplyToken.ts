import { Signature, Wallet, parseUnits } from "ethers";
import { resolve } from "path";
import { config as envConfig } from "dotenv";
import { JsonRpcProvider } from "ethers";
import TOKEN from "./artifacts/@aave/core-v3/contracts/mocks/tokens/MintableERC20.sol/MintableERC20.json";
import POOL from "./artifacts/@aave/core-v3/contracts/protocol/pool/Pool.sol/Pool.json";
import { Contract } from "ethers";

envConfig({ path: resolve(__dirname, "./.env") });

const privateKey = process.env.DEPLOYER_PRIVATE_KEY ?? `0x${"F".repeat(64)}`;
const url = process.env.RPC ?? "https://example-rpc.com";
const args = process.argv.slice(2);
const assetAddr = args[0] ?? "0x286B8DecD5ED79c962b2d8F4346CD97FF0E2C352"; // usdt
const supplyAmount = args[1] ?? "100"; 

async function main() {
  const rpc = new JsonRpcProvider(url);
  const wallet = new Wallet(privateKey, rpc);

  let version = "1";
  let chainId = (await rpc.getNetwork()).chainId;

  let owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; //deployer
  let spender = "0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A"; //pool

  let deadline = Math.floor(Date.now() / 1000) + 10800; //当前时间 + 3小时
  const asset = new Contract(assetAddr, TOKEN.abi, rpc);
  const decimal = Number(await asset.decimals());
  const amountInWei = parseUnits(supplyAmount, decimal);
  const name = await asset.name();
  const pool = new Contract(spender, POOL.abi, wallet);
  const nonce = await asset.nonces(owner);

  const domain = {
    name,
    version,
    chainId,
    verifyingContract: assetAddr,
  };

  const types = {
    Permit: [
      {
        name: "owner",
        type: "address",
      },
      {
        name: "spender",
        type: "address",
      },
      {
        name: "value",
        type: "uint256",
      },
      {
        name: "nonce",
        type: "uint256",
      },
      {
        name: "deadline",
        type: "uint256",
      },
    ],
  };

  const values = {
    owner,
    spender,
    value: amountInWei,
    nonce,
    deadline,
  };

  const signature = Signature.from(await wallet.signTypedData(domain, types, values));

  const tx = await pool.supplyWithPermit(
    assetAddr,
    amountInWei,
    owner,
    0,
    deadline,
    signature.v,
    signature.r,
    signature.s
  );

  console.log("Waiting for Tx receipt.......");
  const receipt = await tx.wait();
  
  console.log(
    `Supplied asset ${name} with permit, total amount: ${supplyAmount}, result: ${receipt.status == 1 ? "success" : "fail"}.`
  );
};

main();