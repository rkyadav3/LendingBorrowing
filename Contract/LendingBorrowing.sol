// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingBorrowing {
    address public owner;

    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interest;
        bool repaid;
    }

    mapping(address => uint256) public lenders;
    Loan[] public loans;

    constructor() {
        owner = msg.sender;
    }

    // Deposit ETH as lender
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be more than 0");
        lenders[msg.sender] += msg.value;
    }

    // Request a loan
    function requestLoan(uint256 _amount, uint256 _interest) public {
        require(_amount > 0, "Amount should be more than 0");
        require(address(this).balance >= _amount, "Insufficient funds in contract");

        loans.push(Loan(msg.sender, _amount, _interest, false));
        payable(msg.sender).transfer(_amount);
    }

    // Repay loan with interest
    function repayLoan(uint256 _loanId) public payable {
        Loan storage loan = loans[_loanId];
        require(msg.sender == loan.borrower, "Only borrower can repay");
        require(!loan.repaid, "Already repaid");

        uint256 totalRepayment = loan.amount + ((loan.amount * loan.interest) / 100);
        require(msg.value >= totalRepayment, "Not enough repayment");

        loan.repaid = true;
    }

    // Withdraw lender funds
    function withdraw(uint256 _amount) public {
        require(lenders[msg.sender] >= _amount, "Insufficient funds to withdraw");
        lenders[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    // View contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
