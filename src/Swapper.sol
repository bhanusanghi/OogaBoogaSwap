// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IOBRouter} from "./IOBRouter.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

struct SingleTokenSwap {
    uint256 inputAmount;
    uint256 outputQuote;
    uint256 outputMin;
    address executor;
    bytes path;
}

contract Swapper {
    using SafeERC20 for IERC20;
    uint32 referralCode = 0;
    IOBRouter public swapRouter =
        IOBRouter(0xF6eDCa3C79b4A3DFA82418e278a81604083b999D);

    function swapTokens(
        SingleTokenSwap calldata swapData,
        address inputToken,
        address outputToken,
        address receiver
    ) external returns (uint256 amountOut) {
        // get tokens from msg.sender

        IERC20(inputToken).safeTransferFrom(
            msg.sender,
            address(this),
            swapData.inputAmount
        );

        IOBRouter.swapTokenInfo memory swapTokenInfo = IOBRouter.swapTokenInfo({
            inputToken: inputToken,
            inputAmount: swapData.inputAmount,
            outputToken: outputToken,
            outputQuote: swapData.outputQuote,
            outputMin: swapData.outputMin,
            outputReceiver: receiver
        });
        return
            _approveRouterAndSwap(
                swapTokenInfo,
                swapData.path,
                swapData.executor
            );
    }

    function _approveRouterAndSwap(
        IOBRouter.swapTokenInfo memory swapTokenInfo,
        bytes calldata path,
        address executor
    ) internal returns (uint256 amountOut) {
        // approve token in to swap router
        IERC20(swapTokenInfo.inputToken).safeIncreaseAllowance(
            address(swapRouter),
            swapTokenInfo.inputAmount
        );
        amountOut = swapRouter.swap(
            swapTokenInfo,
            path,
            executor,
            referralCode
        );
    }

}
