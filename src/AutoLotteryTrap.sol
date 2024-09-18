// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ITrap} from "lib/ITrap.sol";
import {Lottery} from "src/Lottery.sol";

struct CollectOutput {
    bool isTriggered;
}

// automates Lottery.sol round cycle
contract AutoLotteryTrap is ITrap {
    // Deployed on Holesky
    Lottery private lottery =
        Lottery(address(0xC83fFB298AcAC98195b485e4c566EAB99814aB57));

    function collect() external view returns (bytes memory) {
        (,,uint256 endTime,uint256 totalAmount,) = lottery.currentRound(); 
        uint256 maxTotalAmount = lottery.maxTotalAmount();
        return
            abi.encode(
                CollectOutput({
                    isTriggered: (endTime <= block.timestamp || totalAmount >= maxTotalAmount)
                })
            );
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure returns (bool, bytes memory) {
        CollectOutput memory output = abi.decode(data[0], (CollectOutput));

        if (output.isTriggered) {
            return (true, bytes(""));
        }

        return (false, bytes(""));
    }
}