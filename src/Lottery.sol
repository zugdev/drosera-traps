// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Lottery is ReentrancyGuard {
    // -- currency
    IERC20 public usd;

    // -- protocol config
    uint256 public roundDuration = 10 minutes;
    uint256 public lowerBound = 1; 
    uint256 public upperBound = 10;

    // -- max total bet amount
    uint256 public maxTotalAmount = 1000e18;
    
    // -- round structure
    struct CurrentRound {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 totalAmount;
        uint256 totalParticipants;
        address[] participants;
    }

    CurrentRound public currentRound;

    // -- bet structure
    struct Bet {
        uint256 number;
        uint256 amount;
    }

    // -- bets mapping (roundId => (bettor => Bet))
    mapping(uint256 => mapping (address => Bet)) public bets;

    /* ========== CONSTRUCTORS ==========*/

    constructor(address _usd) {
        // -- set currency
        usd = IERC20(_usd);
        
        // -- start first round
        currentRound.id = 0;
        currentRound.startTime = block.timestamp;
        currentRound.endTime = block.timestamp + roundDuration;
        currentRound.totalAmount = 0;
        currentRound.totalParticipants = 0;
        currentRound.participants = new address[](0);
    }

    /* ============ EXTERNAL ============*/

    function bet(uint256 number, uint256 amount) external nonReentrant {
        require(bets[currentRound.id][msg.sender].amount == 0, "Lottery: you already bet in this round");
        require(number >= lowerBound && number <= upperBound, "Lottery: number out of bounds");
        require((block.timestamp >= currentRound.startTime) && (block.timestamp < currentRound.endTime), "Lottery: round not started yet");
        require(amount > 0, "Lottery: amount must be greater than 0");
        require(usd.allowance(msg.sender, address(this)) >= amount, "Lottery: insufficient allowance");
        require(usd.balanceOf(msg.sender) >= amount, "Lottery: insufficient balance");
        require(currentRound.totalAmount + amount <= maxTotalAmount, "Lottery: max total amount reached");

        // -- transfer the bet amount
        usd.transferFrom(msg.sender, address(this), amount);

        // -- update the bet
        bets[currentRound.id][msg.sender] = Bet(number, amount);

        // -- update the round
        currentRound.totalAmount += amount;
        currentRound.totalParticipants++;
        currentRound.participants.push(msg.sender);

        emit BetPlaced(msg.sender, currentRound.id, number, amount);
    }

    function endRound() external nonReentrant {
        require((block.timestamp >= currentRound.endTime) || (currentRound.totalAmount >= maxTotalAmount), "Lottery: round not ended yet");
        _payout();
        _startNewRound();
    }

    /* ============ INTERNAL ============*/

    function _payout() internal {
        // generate a pseudorandom number between 1 and 10 (this is trash, don't use it in prod)
        uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, currentRound.participants))) % upperBound) + lowerBound;

        emit RoundEnded(currentRound.id, randomNumber);

        // -- distribute the pot
        uint256 participantsLength = currentRound.participants.length;
        for (uint256 i = 0; i < participantsLength; i++) {
            if (bets[currentRound.id][currentRound.participants[i]].number == randomNumber) {
                // prize is double the bet
                uint256 prize = 2 * bets[currentRound.id][currentRound.participants[i]].amount;
                usd.transfer(currentRound.participants[i], prize);
                emit PrizePaid(currentRound.participants[i], prize);
            }   
        }
    }

    function _startNewRound() internal {
        currentRound.id++;
        currentRound.startTime = block.timestamp;
        currentRound.endTime = block.timestamp + roundDuration;
        currentRound.totalAmount = 0;
        currentRound.totalParticipants = 0;
        currentRound.participants = new address[](0) ;

        emit NewRoundStarted(currentRound.id);
    }

    /* ============= EVENTS =============*/

    event BetPlaced(address indexed bettor, uint256 roundId, uint256 number, uint256 amount);
    event RoundEnded(uint256 roundId, uint256 winningNumber);
    event PrizePaid(address indexed winner, uint256 prizeAmount);
    event NewRoundStarted(uint256 newRoundId);
}
