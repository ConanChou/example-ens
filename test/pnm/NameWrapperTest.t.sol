// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/ethregistrar/BaseRegistrarImplementation.sol";
import "contracts/registry/ENSRegistry.sol";
import "contracts/wrapper/IMetadataService.sol";
import "contracts/wrapper/NameWrapper.sol";
import "contracts/wrapper/StaticMetadataService.sol";
import "@pwnednomore/contracts/Agent.sol";

contract NameWrapperTest is Agent {
    ENSRegistry internal ens;
    BaseRegistrarImplementation internal baseRegistrar;
    StaticMetadataService internal metaDataService;
    NameWrapper internal nameWrapper;

    bytes32 internal constant ROOT_NODE = 0x0;

    bytes32 ethId =
        keccak256(abi.encodePacked(ROOT_NODE, keccak256(bytes("eth"))));

    function deploy() internal {
        ens = new ENSRegistry();

        baseRegistrar = new BaseRegistrarImplementation(
            ens,
            keccak256(abi.encodePacked(ROOT_NODE, keccak256(bytes("eth"))))
        );

        metaDataService = new StaticMetadataService("https://ens.domains");

        nameWrapper = new NameWrapper(
            ens,
            baseRegistrar,
            IMetadataService(address(metaDataService))
        );

        ens.setSubnodeOwner(
            ROOT_NODE,
            keccak256(bytes("eth")),
            address(baseRegistrar)
        );

        baseRegistrar.addController(address(nameWrapper));
    }

    function registerNode(string memory label) internal returns (bytes32 id) {
        nameWrapper.setController(address(this), true);

        nameWrapper.registerAndWrapETH2LD(
            label,
            address(this),
            10 * 365 days,
            address(0x0000000000000000000000000000000000000000),
            0, // CAN_DO_EVERYTHING
            uint64(block.timestamp + 10 * 365 days)
        );

        id = keccak256(abi.encodePacked(ethId, keccak256(bytes(label))));

        nameWrapper.setController(address(this), false);
    }

    function registerSubNode(bytes32 id, string memory label)
        internal
        returns (bytes32 subId)
    {
        nameWrapper.setSubnodeOwner(
            id,
            label,
            address(this),
            0,
            uint64(block.timestamp + 10 * 365 days)
        );

        subId = keccak256(abi.encodePacked(id, keccak256(bytes(label))));
    }

    function expiry(bytes32 id) internal returns (uint64 time) {
        (, time) = nameWrapper.getFuses(id);
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}