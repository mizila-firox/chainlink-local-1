// test/demo.t.sol

pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {CCIPLocalSimulator} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";

// firox
import {CCIPSender_Unsafe} from "lib/chainlink-local/src/test/ccip/CCIPSender_Unsafe.sol";
import {CCIPReceiver_Unsafe} from "lib/chainlink-local/src/test/ccip/CCIPReceiver_Unsafe.sol";

contract Demo is Test {
    CCIPLocalSimulator public ccipLocalSimulator;

    // firox
    CCIPSender_Unsafe public sender;
    CCIPReceiver_Unsafe public receiver;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();

        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            WETH9 wrappedNative,
            LinkToken linkToken,
            BurnMintERC677Helper ccipBnM,
            BurnMintERC677Helper ccipLnM
        ) = ccipLocalSimulator.configuration();

        sender = new CCIPSender_Unsafe(
            address(linkToken),
            address(sourceRouter)
        );
        receiver = new CCIPReceiver_Unsafe(address(destinationRouter));

        ccipLocalSimulator.requestLinkFromFaucet(address(sender), 2 ether);

        // firox
        ccipBnM.drip(address(sender));

        sender.send(
            address(receiver),
            "working locally",
            chainSelector,
            address(ccipBnM),
            0.1 ether
        );
    }

    function testFoo() external {
        string memory text = receiver.text();
        console2.logString(text);
    }
}
