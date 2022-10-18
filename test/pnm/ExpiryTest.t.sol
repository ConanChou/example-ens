// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NameWrapperTest.t.sol";

contract ExpiryTest is NameWrapperTest {
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

    function invariantExpiryOrder() public {
        // INVARIANT:
        // A parent domain always expires later than a child domain
        require(
            expiry(subId) >= expiry(subSubId),
            "Sub domain expires later than its parent."
        );
    }
}
