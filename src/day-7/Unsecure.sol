// SPDX-License-Identifier: MIT
// @note バージョン特有のバグあるかも？
pragma solidity =0.8.16;

contract BBB {

  /*********************************************************************************************
   ************************************   VARIABLES     ****************************************
   *********************************************************************************************/

  uint constant REWARD_RATE = 50;
  // 関数のaddressは適当です
  address constant BBBToken = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
  // @note contructor使わなくて良い？msg.sender変わりうる？
  address owner = msg.sender;
  address[] approvedTokens; /// JPYC, USDC, USDTのみがownerからapproveされます
  address[] whitelist;
  mapping(address => mapping(address => DepostInfo)) depositAmt;

  /*********************************************************************************************
   ************************************     STRUCT     ****************************************
   *********************************************************************************************/

  struct DepostInfo {
    uint lastTime;      /// 32 bytes
    uint amount;        /// 32 bytes
  }

  struct TransferInfo {
    // @note 後でbool呼んでいて、型が違うのでエラーになる?
    bool isETH;         /// 32 bytes
    uint amount;        /// 32 bytes
    address token;      /// 20 bytes
    address from;       /// 20 bytes
    address to;         /// 20 bytes
  }

  /*********************************************************************************************
   *********************************   OWNER FUNCTIONS     *************************************
   *********************************************************************************************/

  /// @notice  approvedTokens配列にtokenを使いするために使用します
  /// @dev     ownerだけが実行できます
  function addApprovedTokens(address _token) private {
    // @audit high owner以外も実行できてしまいそう
    if (msg.sender != owner) revert();
    approvedTokens.push(_token);
  }

  /*********************************************************************************************
   *******************************   VIEW | PURE FUNCTIONS     *********************************
   *********************************************************************************************/

  /// @notice
  /// @dev     Can call only owner
  function getReward(address token) public view returns (uint reward) {
    uint amount = depositAmt[msg.sender][token].amount;
    uint lastTime = depositAmt[msg.sender][token].lastTime;
    // @note safeMath
    // @note block.timestamp
    // @note logicおかしい？
    // @audit rewardが預けた時間が短いほど高くなるロジックのため、意図せず短期間で大量のBBBトークンを放出してしまう可能性がある
    reward = (REWARD_RATE / (block.timestamp - lastTime)) * amount;
  }

  function _isXXX(
    address _token,
    address[] memory _xxx
  ) private pure returns (bool) {
    uint length = _xxx.length;
    // @note 初期化必要そう
    // @note 大丈夫っぽい https://ethereum.stackexchange.com/questions/51076/does-a-for-loop-set-the-input-integer-to-zero
    for (uint i; i < length; ) {
      if (_token == _xxx[i]) return true;
      unchecked {
        ++i;
      }
    }
    return false;
  }

  /*********************************************************************************************
   *********************************   PUBLIC FUNCTIONS     ************************************
   *********************************************************************************************/

  function addWhitelist(address _token) public {
    if (!_isXXX(_token, approvedTokens)) revert();
    whitelist.push(_token);
  }

  function deposit(uint _amount, address _token, bool _isETH) public {
    if (!_isXXX(_token, whitelist)) revert();
    DepostInfo memory depositInfo;
    TransferInfo memory info = TransferInfo({
        // @note isEth自己申告制
        // @note 型が違う
        isETH: _isETH,
        token: _token,
        from: msg.sender,
        //@note amount check
        amount: _amount,
        to: address(this)
    });

    _tokenTransfer(info);
    //@audit depositを2回呼ぶと1回目の預けたトークンの情報が失われる
    depositInfo.lastTime = uint40(block.timestamp);
    depositInfo.amount = _amount;
    depositAmt[msg.sender][_token] = depositInfo;
  }

  function withdraw(
    address _to,
    uint _amount,
    bool _isETH,
    address _token
  ) public {
    if (!_isXXX(_token, whitelist)) revert();
    TransferInfo memory info = TransferInfo({
        isETH: _isETH,
        token: _token,
        from: address(this),
        amount: _amount,
        to: _to
    });
    uint canWithdrawAmount = depositAmt[msg.sender][_token].amount;
    //@audit 預けた金額と同額を引き出せない
    require(info.amount < canWithdrawAmount, "ERROR");
    // @note memoryの値なので書き換える必要ない？
    canWithdrawAmount = 0;
    _tokenTransfer(info);
    // @audit 悪意がなくても無限に引き落とせそう。storageのamountを書き換えていない
    uint rewardAmount = getReward(_token);
    // @note safeTransfer
    // @note reentrancy, getRewardが2回呼べそう
    IERC20(BBBToken).transfer(msg.sender, rewardAmount);
  }

  /*********************************************************************************************
   *********************************   PRIVATE FUNCTIONS     ***********************************
   *********************************************************************************************/
  function _tokenTransfer(TransferInfo memory _info) private {
    // @note ETHのチェックが自己申告制なのは気になる
    if (_info.isETH) {
      (bool success, ) = _info.to.call{ value: _info.amount }("");
      require(success, "Failed");
    } else {
      //@note safeTransferFrom
      IERC20(_info.token).transferFrom(_info.from, _info.to, _info.amount);
    }
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function transfer(address recipient, uint amount) external returns (bool);

  function allowance(
    address owner,
    address spender
  ) external view returns (uint);

  function approve(address spender, uint amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
