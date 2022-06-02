pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  bool OpenForWithdrawal;
  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 30 seconds;

  mapping(address => uint256) public balances;

  event Stake(address indexed _staker, uint256 indexed _amount);

  function stake(address staker, uint256 amount) public payable returns (bool success) {
    balances[staker] += amount;
    success = true;
    emit Stake(staker, amount);
    console.log('balance', balances[staker]);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public returns (bool openForWithdraw) {
    //uint256 _timeleft = timeLeft();
    // if (_timeleft == 0) {

    // } else {
    //   // timeLeft();1000000000000000000
    // }
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else if (address(this).balance < threshold) {
      openForWithdraw = true;
    }
  }

  function withdraw() public {
    // assert(OpenForWithdrawal == true);
    uint256 amount = balances[msg.sender];
    (bool os, ) = payable(msg.sender).call{value: amount}('');
    require(os);
  }

  //2994.6710
  function timeLeft() public view returns (uint256 _deadline) {
    _deadline = block.timestamp;
    uint256 newDeadline = deadline - _deadline;
    if (newDeadline == deadline) {
      return 0;
    } else if (_deadline < deadline) {
      _deadline++;
    }

    return newDeadline;
  }

  // receive()external payable{
  //   stake(msg.sender, msg.value);
  // }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // TODO: Add the `receive()` special function that receives eth and calls stake()
}
