# Putty V2

取引板型の ERC20/721 用オプションマーケット.
[foundry](foundry.sh)製。
詳しくは [spec](./spec/).

## 初めに

1. Install `foundry`, refer to [foundry](https://github.com/foundry-rs/foundry)
2. Install `nodejs`, refer to [nodejs](https://nodejs.org/en/)
3. Install `yarn`, `npm install --global yarn`

次に、

```
git clone git@github.com:neila/BBB-day5-teamD.git
yarn install
forge install
forge test --gas-report
```

## テスト

テストキットは `./test/`.
差動テストは `./test/differential/`. デフォルトでオフになっている。オンにする方法は `./test/differential/README.md` 参照。

```
forge test --gas-report
```

## 静的解析

静的解析には [slither](https://github.com/crytic/slither)を使用.

インストール:

```
pip3 install slither-analyzer
pip3 install solc-select
solc-select install 0.8.13
solc-select use 0.8.13
```

実行:

```
slither ./src/PuttyV2.sol --solc-args "--optimize --optimize-runs 100000"
```
