// SPDX-License-Identifier: MIT pragma solidity ^0.8.0;

contract DecentralizedExamSystem { address public admin; uint256 public examCount;

struct Exam {
    string questionHash; // IPFS hash or off-chain hash of questions
    bool isActive;
    uint256 startTime;
    uint256 duration; // in seconds
}

mapping(uint256 => Exam) public exams;
mapping(uint256 => mapping(address => string)) public submissions;
mapping(uint256 => mapping(address => bool)) public hasSubmitted;

event ExamCreated(uint256 indexed examId, string questionHash);
event AnswerSubmitted(uint256 indexed examId, address student);
event ExamClosed(uint256 indexed examId);

constructor() {
    admin = msg.sender;
}

modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can perform this action");
    _;
}

modifier isExamActive(uint256 _examId) {
    require(exams[_examId].isActive, "Exam is not active");
    require(block.timestamp <= exams[_examId].startTime + exams[_examId].duration, "Exam time over");
    _;
}

function createExam(string calldata _questionHash, uint256 _startTime, uint256 _duration) external onlyAdmin {
    exams[examCount] = Exam(_questionHash, true, _startTime, _duration);
    emit ExamCreated(examCount, _questionHash);
    examCount++;
}

function submitAnswer(uint256 _examId, string calldata _answerHash) external isExamActive(_examId) {
    require(!hasSubmitted[_examId][msg.sender], "Already submitted");
    submissions[_examId][msg.sender] = _answerHash;
    hasSubmitted[_examId][msg.sender] = true;
    emit AnswerSubmitted(_examId, msg.sender);
}

function closeExam(uint256 _examId) external onlyAdmin {
    exams[_examId].isActive = false;
    emit ExamClosed(_examId);
}

function getExamDetails(uint256 _examId) external view returns (string memory, bool, uint256, uint256) {
    Exam memory e = exams[_examId];
    return (e.questionHash, e.isActive, e.startTime, e.duration);
}

function hasStudentSubmitted(uint256 _examId, address _student) external view returns (bool) {
    return hasSubmitted[_examId][_student];
}

}
