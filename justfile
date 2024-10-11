set dotenv-load
default: 
  just --list

# Asset address
usdt := "0x286B8DecD5ED79c962b2d8F4346CD97FF0E2C352"
dai := "0x742489F22807ebB4C36ca6cD95c3e1C044B7B6c8"
link := "0x1D8D70AD07C8E7E442AD78E4AC0A16f958Eba7F0"
usdc := "0xA9e6Bfa2BF53dE88FEb19761D9b2eE2e821bF1Bf"
wbtc := "0x1E3b98102e19D3a164d239BdD190913C2F02E756"
weth := "0x3fdc08D815cc4ED3B7F69Ee246716f2C8bCD6b07"
aave := "0xb868Cc77A95a65F42611724AF05Aa2d3B6Ec05F2"
eurs := "0x70E5370b8981Abc6e14C91F4AcE823954EFC8eA3"

# Useful address
pool := "0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A"
faucet := "0x666D0c3da3dBc946D5128D06115bb4eed4595580"
deployer := "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
ethgateway := "0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a"

# View
# set env variable `scrollsdk` in advance
check_pool:
  cast call --rpc-url $scrollsdk 0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A "POOL_REVISION()"

check_reserve_list:
  cast call --rpc-url $scrollsdk 0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A "getReservesList()(address[])"

get_reserve_data asset=usdt :
  echo 'Get reserve data for asset #{{asset}}'
  cast call --rpc-url $scrollsdk 0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A "getReserveData(address)(uint256,uint128,uint128,uint128,uint128,uint128,uint40,uint16,address,address,address,address,uint128,uint128,uint128)" "{{asset}}"

get_account_data account:
  echo 'Get account data for account #{{account}}'
  cast call --rpc-url $scrollsdk 0x63F22329e0693271eAA5cBACB5D4F3218eB3F29A "getUserAccountData(address)(uint256,uint256,uint256,uint256,uint256,uint256)" "{{account}}"



# Faucet
# default recipient: deployer amount: 1000 usdt
faucet_usdt amount="1000000000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{usdt}} {{recipient}} {{amount}}

# default recipient: deployer amount: 100 usdt
faucet_dai amount="1000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{dai}} {{recipient}} `cast to-wei {{amount}}`

# default recipient: deployer amount: 1000 usdc
faucet_usdc amount="1000000000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{usdc}} {{recipient}} {{amount}}

faucet_wbtc amount="1000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{wbtc}} {{recipient}} `echo $(({{amount}}*10**8))`

faucet_aave amount="1000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{aave}} {{recipient}} `cast to-wei {{amount}}`

faucet_eurs amount="1000" recipient=deployer:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{faucet}} "mint(address,address,uint256)" {{eurs}} {{recipient}} `echo $(({{amount}}*10**2))`

# Pool
supply_usdt amount="100":
  ts-node ./supplyToken.ts {{usdt}} {{amount}}

supply_dai amount="100":
  ts-node ./supplyToken.ts {{dai}} {{amount}}

supply_usdc amount="100":
  ts-node ./supplyToken.ts {{usdc}} {{amount}}

supply_wbtc amount="100":
  ts-node ./supplyToken.ts {{wbtc}} {{amount}}

supply_aave amount="100":
  ts-node ./supplyToken.ts {{aave}} {{amount}}

supply_eurs amount="100":
  ts-node ./supplyToken.ts {{eurs}} {{amount}}

supply_eth amount="100":
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{ethgateway}} "depositETH(address,address,uint16)" {{pool}} {{deployer}} 0 --value `cast to-wei {{amount}}`
  
borrow_usdt:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{pool}} "borrow(address,uint256,uint256,uint16,address)" {{usdt}} 1000000 1 0 {{deployer}}

set_collateral asset:
  cast send --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $scrollsdk {{pool}} "setUserUseReserveAsCollateral(address,bool)" {{asset}} true



# Utils
decimals asset:
  cast call --rpc-url $scrollsdk {{asset}} "decimals()(uint256)"