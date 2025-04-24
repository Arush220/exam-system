// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedExamSystem {
    address public admin;

    struct Exam {
        string questionHash; // IPFS hash or off-chain hash of questions
        bool isActive;
    }

    Exam public exam;
    mapping(address => string) public submissions;
    mapping(address => bool) public hasSubmitted;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function createExam(string calldata _questionHash) external onlyAdmin {
        exam = Exam(_questionHash, true);
    }

    function submitAnswer(string calldata _answerHash) external {
        require(exam.isActive, "Exam not active");
        require(!hasSubmitted[msg.sender], "Already submitted");
        submissions[msg.sender] = _answerHash;
        hasSubmitted[msg.sender] = true;
    }

    function closeExam() external onlyAdmin {
        exam.isActive = false;
    }
}

