// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FuzzENS.t.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FuzzENSExpiry is FuzzENS {
    bytes32 pnmId;
    bytes32 subId;
    bytes32 subSubId;

    function setUp() public {
        // Step 1. Deploy all the smart contracts
        deploy();

        // Step 2. Register pnm.eth
        pnmId = registerNode("pnm");

        // Step 3. Register sub.pnm.eth
        subId = registerSubNode(pnmId, "sub");

        // Step 4. Register subsub.sub.pnm.eth
        subSubId = registerSubNode(subId, "subsub");
    }

    function check() public override {
        uint256 parentExpiry = expiry(subId);
        uint256 childExpiry = expiry(subSubId);

        // INVARIANT
        require(
            parentExpiry >= childExpiry,
            string(
                abi.encodePacked(
                    "[!!!] Invariant broken: Sub domain (",
                    Strings.toString(childExpiry),
                    ") lives longer than its parent (",
                    Strings.toString(parentExpiry),
                    ")"
                )
            )
        );
    }
}