// SPDX-License-Identifier: MIT
pragma solidity^0.8.3;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// the IERC20 interface lists functions available but no definitions
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SimpleMultisigWalletV2 is Initializable { // POC for MTS Safe

  address public superowner;
  address[] public owners;
  uint public numConfirmationsRequired;
  mapping(address => bool) public isOwner;

  // function initialize(uint _numConfirmationsRequired) public initializer {
  //   superowner = msg.sender;
  //   numConfirmationsRequired = _numConfirmationsRequired;
  // }

  function initialize(address[] memory _owners, uint _numConfirmationsRequired) public initializer {
    //require(msg.sender == superowner, "only owner able to do this function");
    require(_owners.length > 0, "owners required");
    require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "invalid number of required confirmations");

    for (uint i = 0; i < _owners.length; i++) {
       address owner = _owners[i];
       require(owner != address(0), "invalid owner");
       require(!isOwner[owner], "owner is existed"); 
       isOwner[owner] = true;
       owners.push(owner);
    }
    numConfirmationsRequired = _numConfirmationsRequired;
  }
  
  struct SendTokenTx {
    IERC20 token;
    address to;
    uint amount;
    bool executed;
    uint numConfirmations;
  }

  struct MultiSendFixedTokenFromContractTx {
    IERC20 token;
    address[] to;
    uint amount;
    bool executed;
    uint numConfirmations;
  }

  SendTokenTx[] public sendTokenTxs;
  MultiSendFixedTokenFromContractTx[] public multiSendFixedTokenFromContractTxs;

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier txExists(uint _txIndex) {
    require(_txIndex < sendTokenTxs.length, "tx does not exist");
    _;
  }

  // modifier notConfirmed(uint _txIndex) {
  //   require(!isConfirmed[_txIndex][msg.sender], "tx have already confirmed by you before");
  //   _;
  // }

  modifier notExecuted(uint _txIndex) {
    require(!sendTokenTxs[_txIndex].executed, "tx already executed");
    _;
  }

  // mapping from fn_index => tx_index => owner => bool
  mapping(uint => mapping(uint => mapping(address => bool))) public isConfirmed;

  // TODO: function index list -> สำหรับใช้ระบุชนิดฟังก์ชั่น

  function specifySuperowner() public { // ใครกดก็ได้ 
    require(owners.length > 0, "owners do not equal to zero");
    superowner = owners[0];
  }

  function deposit() external payable {}

  function balanceOf(IERC20 _token) public view returns (uint) {
    uint balance = _token.balanceOf(address(this));
    return balance;
  }

  function getTxCount(uint _txType) public view returns (uint) {
    if (_txType == 1) { return sendTokenTxs.length; }
    // TODO: another types
    if (_txType == 2) { return multiSendFixedTokenFromContractTxs.length; }
  }

  function getSendTokenTxInfo(uint _sendTokenTxIndex) public view returns (
    IERC20 token,
    address to,
    uint amount,
    bool executed,
    uint numConfirmations
  ) {
    SendTokenTx storage transaction = sendTokenTxs[_sendTokenTxIndex];
    return (
      transaction.token,
      transaction.to,
      transaction.amount,
      transaction.executed,
      transaction.numConfirmations
    );
  }

  function getMultiSendFixedTokenFromContractTxInfo(uint _multiSendFixedTokenFromContractTxIndex) public view returns (
    IERC20 token,
    address[] memory to,
    uint amount,
    bool executed,
    uint numConfirmations
  ) {
    MultiSendFixedTokenFromContractTx storage transaction = multiSendFixedTokenFromContractTxs[_multiSendFixedTokenFromContractTxIndex];
    return (
      transaction.token,
      transaction.to,
      transaction.amount,
      transaction.executed,
      transaction.numConfirmations
    );
  }

  // TODO: if function for submit, confirm, execute
  function submitSendTokenTx(IERC20 _token, address _to, uint _amount) public onlyOwner {
    sendTokenTxs.push(
      SendTokenTx({
        token: _token,
        to: _to,
        amount: _amount,
        executed: false,
        numConfirmations: 0
      })
    );
  } 

  function submitMultiSendFixedTokenFromContractTx(IERC20 _token, address[] memory _to, uint _amount) public onlyOwner {
    multiSendFixedTokenFromContractTxs.push(
      MultiSendFixedTokenFromContractTx({
        token: _token,
        to: _to,
        amount: _amount,
        executed: false,
        numConfirmations: 0
      })
    );
  }

  // TODO: confirm tx (for each functions)
  function confirmSendTokenTx(uint _sendTokenTxIndex) public onlyOwner {
    require(!isConfirmed[1][_sendTokenTxIndex][msg.sender], "tx have already confirmed by you before");
    SendTokenTx storage transaction = sendTokenTxs[_sendTokenTxIndex];
    transaction.numConfirmations += 1;
    isConfirmed[1][_sendTokenTxIndex][msg.sender] = true;
  }

  function confirmMultiSendFixedTokenFromContractTx(uint _multiSendFixedTokenFromContractTxIndex) public onlyOwner {
    require(!isConfirmed[2][_multiSendFixedTokenFromContractTxIndex][msg.sender], "tx have already confirmed by you before");
    MultiSendFixedTokenFromContractTx storage transaction = multiSendFixedTokenFromContractTxs[_multiSendFixedTokenFromContractTxIndex];
    transaction.numConfirmations += 1;
    isConfirmed[2][_multiSendFixedTokenFromContractTxIndex][msg.sender] = true;
  }

  // execute SendToken
  function exeSendTokenTx(uint _sendTokenTxIndex) internal {
    SendTokenTx storage transaction = sendTokenTxs[_sendTokenTxIndex];
    require(transaction.executed == false);
    require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx bec number of confirmation less than required number");
    require(transaction.token.balanceOf(address(this)) >= transaction.amount, "check the contract token balance");
    transaction.executed = true;
    transaction.token.transfer(transaction.to, transaction.amount);
  }

  function exeMultiSendFixedTokenFromContractTx(uint _multiSendFixedTokenFromContractTxIndex) internal {
    MultiSendFixedTokenFromContractTx storage transaction = multiSendFixedTokenFromContractTxs[_multiSendFixedTokenFromContractTxIndex];
    require(transaction.executed == false);
    require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx bec number of confirmation less than required number");
    require(transaction.to.length > 0);
    require(transaction.amount > 0);
    require(transaction.to.length * transaction.amount <= transaction.token.balanceOf(address(this)));
        
    for (uint256 i = 0; i < transaction.to.length; i++) {
        transaction.token.transfer(transaction.to[i], transaction.amount);
    }
  }

  // TODO: Batch execution for the Superowner
  function batchExeSendTokenTx(uint [] memory _selectedTxIndexList) public onlyOwner {
    // TODO: 1) re-use exe function -> internal 2) executed tx list
    require (_selectedTxIndexList.length != 0, "do not provide empty list");
    uint i = 0; 
    uint j = _selectedTxIndexList.length;
    while(i < j) { // กรณี j = 1 คือกรณีส่ง tx index เดียว
      exeSendTokenTx(_selectedTxIndexList[i]);
      i += 1;
    } 
  }

  function batchExeMultiSendFixedTokenFromContractTx(uint [] memory _selectedTxIndexList) public onlyOwner {
    require (_selectedTxIndexList.length != 0, "do not provide empty list");
    uint i = 0; 
    uint j = _selectedTxIndexList.length;
    while(i < j) { 
      exeMultiSendFixedTokenFromContractTx(_selectedTxIndexList[i]);
      i += 1;
    } 
  }

  function multiBatchExeTx(uint [] memory _selectedSendTokenTxIndexList, uint [] memory _selectedMultiSendFixedTokenFromContractTxIndexList) public onlyOwner {
    require (_selectedSendTokenTxIndexList.length != 0 && _selectedMultiSendFixedTokenFromContractTxIndexList.length != 0, "do not provide empty list");
    uint i = 0; 
    uint j = _selectedSendTokenTxIndexList.length;
    while(i < j) { 
      exeSendTokenTx(_selectedSendTokenTxIndexList[i]);
      i += 1;
    } 
    i = 0;
    j = _selectedMultiSendFixedTokenFromContractTxIndexList.length;
    while(i < j) { 
      exeMultiSendFixedTokenFromContractTx(_selectedMultiSendFixedTokenFromContractTxIndexList[i]);
      i += 1;
    } 
  }
  // TODO: another functions
}