pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  bool OpenForWithdrawal;

  bool called;

  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 72 hours;

  mapping(address => uint256) public balances;

  struct state {
    bool called;
  }

  event Stake(address indexed _staker, uint256 indexed _amount);

  modifier OpenForWithdrawal_() {
    bool _OpenForWithdrawal = OpenForWithdrawal;
    require(_OpenForWithdrawal == true, 'Withdraw not opened yet');
    _;
  }

  function stake() public payable returns (bool success) {
    require(msg.value > 0, '');
    balances[msg.sender] += msg.value;
    success = true;
    emit Stake(msg.sender, msg.value);
    OpenForWithdrawal = false;
    called = true;
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public {
    require(called == true, '');
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else if (address(this).balance < threshold) {
      OpenForWithdrawal = true;
    }
    called = false;
    //10000000000000000000
    //500000000000000000
  }

  function withdraw() public OpenForWithdrawal_ {
    uint256 amount = balances[msg.sender];
    (bool os, ) = payable(msg.sender).call{value: amount}('');
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  receive() external payable {
    stake();
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // TODO: Add the `receive()` special function that receives eth and calls stake()
}
