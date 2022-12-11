# Putty V2

取引板型の ERC20/721 用オプションマーケット.
[foundry](foundry.sh)製。
詳しくは [spec](./spec/).

## 初めに

1. Install `foundry`, refer to [foundry](https://github.com/foundry-rs/foundry)
2. Install `nodejs`, refer to [nodejs](https://nodejs.org/en/)
3. Install `yarn`, `npm install --global yarn`

環境構築:

```
git clone git@github.com:neila/BBB-day5-teamD.git
yarn install
forge install foundry-rs/forge-std  Rari-Capital/solmate OpenZeppelin/openzeppelin-contracts
```

## テスト

テストキットは `./test/`.
差動テストは `./test/differential/`. デフォルトでオフになっている。オンにする方法は `./test/differential/README.md` 参照。

テスト:

```
forge test --gas-report
```

## 静的解析

静的解析には [slither](https://github.com/crytic/slither)を使用.

環境構築:

```
python3 -m venv .pyenv
source .pyenv/bin/activate
python -m pip install -r requirements.txt
solc-select install 0.8.16
solc-select use 0.8.16
```

実行:

```
yarn slither
```
