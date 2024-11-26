// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Surl} from "surl/Surl.sol";
import {Script, console} from "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/console.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Swapper, SingleTokenSwap} from "../src/Swapper.sol";

contract SwapUsingOBRouter is Script {
    using Strings for uint256;
    using Surl for string;
    using stdJson for string;
    using Strings for address;

    string apiKey = vm.envString("OOGABOOGA_API_KEY");
    address public swapper = 0x;
    uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address pkAddress = vm.addr(pk);
    //For OB Router Range from 0 to 1 to allow for price slippage
    function getSwapData(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        address to
    ) public returns (uint256, uint256, uint256, address, string memory) {
        // use ffi to run a CURL command and get the data.
        string memory url = string(
            abi.encodePacked(
                "https://bartio.api.oogabooga.io/v1/swap/?tokenIn=",
                tokenIn.toHexString(),
                "&tokenOut=",
                tokenOut.toHexString(),
                "&amount=",
                amount.toString(),
                "&to=",
                to.toHexString()
            )
        );
        string[] memory headers = new string[](1);
        headers[0] = string(abi.encodePacked("Authorization: Bearer ", apiKey));
        (uint256 _status, bytes memory data) = url.get(headers);
        console.log("status: ", _status);
        string memory json = string(data);
        // validate response and get data of interest
        uint256 outputQuote = json.readUint(
            ".routerParams.swapTokenInfo.outputQuote"
        );
        uint256 outputMin = json.readUint(
            ".routerParams.swapTokenInfo.outputMin"
        );
        string memory path = json.readString(".routerParams.pathDefinition");
        address executor = json.readAddress(".routerParams.executor");

        // Log data
        // console.log("tokenIn: ", tokenIn);
        // console.log("tokenOut: ", tokenOut);
        // console.log("inputAmount: ", amount);
        // console.log("outputQuote: ", outputQuote);
        // console.log("outputMin: ", outputMin);
        // console.log("executor: ", executor);
        // console.log("pathDef: ");
        // console.logString(path);

        // return data
        return (amount, outputQuote, outputMin, executor, path);
    }

    function run() external {
        address yeet = 0x1740F679325ef3686B2f574e392007A92e4BeD41;
        address wBera = 0x7507c1dc16935B82698e4C63f2746A2fCf994dF8;
        uint inputAmount = 1 ether;
        // get current block number
        console.log("block number: ", block.number);

        // ######## reward harvest data ########
        // obero
        (uint inputAmount,uint256 outputQuote,uint256 outputMin,address executor, string memory path) = getSwapData(wBera, yeet, inputAmount, pkAddress);

        SingleTokenSwap memory swapData = SingleTokenSwap({
            inputAmount: inputAmount,
            outputQuote: outputQuote,
            outputMin: outputMin,
            executor: executor,
            path: path
        });

        Swapper swapper = Swapper(payable(swapper));
        uint256 amountOut = swapper.swapTokens(swapData, wBera, yeet, pkAddress);
    }
}
