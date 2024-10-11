# Devnet Environment Description

本篇文档用于记录Aave v3 在scroll devnet测试环境中的流动性配置情况，以及aave protocol中的一些基本entry point介绍。

## 流动性 setup

当前，devnet上部署了几个常见的ERC20 token，其地址设置详见[deployment.md](deployment.md#mintable-reserves-and-rewards)。

Set up的相关信息如下：

- 当前`Pool`中这几个代币的流动性，我们都已经提供，每个token都被提供了至少100个token的储备量。
- 在production环境中，每个asset price 都由真实的oracle 提供（如chainlink)。在我们的devnet环境下，我们采用了mock的数据，详情可以查看[`MOCK_CHAINLINK_AGGREGATORS_PRICES`](https://github.com/SpaceStation09/aave-v3-deploy-devnet/blob/3c34a86361d1b54c6a0beff09e9803524bc446b8/helpers/constants.ts#L54)

## 功能入口

### ETH

- 如果需要为ETH提供流动性，请与`WrappedTokenGatewayV3`合约交互，其中有`depositETH()`,`withdrawETH()`等方法，以完成流动性的提供和撤出。
- 如果需要借出和偿还ETH，请与`WrappedTokenGatewayV3`合约交互，其中有`borrowETH()`,`repayETH()`等方法。

[查看`WrappedTokenGatewayV3`的接口](https://docs.aave.com/developers/periphery-contracts/wethgateway)

### ERC20

- 如果需要为ERC20 token提供流动性，请与`Pool`合约交互，其中有`supply()`,`supplyWithPermit()`等方法，以完成流动性的提供和撤出。
- 如果需要借出和偿还ERC20 token，请与`Pool`合约交互，其中有`borrow()`,`repay()`等方法, 此外，你还可以使用AToken以完成债务的偿还。
- 在借出资产前，你需要确认，你是否已有抵押品，或者你的抵押品asset 是否被设置为used as collateral (可以通过`setUserUseReserveAsCollateral()`方法完成设置)。
- 你可以通过`getUserAccountData()`查看你当前的抵押价值/credit，以及debt。

[查看`Pool`的接口](https://docs.aave.com/developers/core-contracts/pool)

> **需要查询以上提到的所有合约在devnet的地址 / 查询devnet上 aave 合约的权限情况，请查看[Deployment.md](deployment.md).**
