// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address usdc;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant BURNER_WALLET = 0xA417D473c40a4d42BAd35f147c21eEa7973539D8;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig config) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaNetworkConfig();
        networkConfigs[ZKSYNC_SEPOLIA_CHAIN_ID] = getZkSyncSepoliaNetworkConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getNetworkConfigByChainId(block.chainid);
    }

    function getNetworkConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthNetworkConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0,
            account: BURNER_WALLET
        });
    }

    function getZkSyncSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0),
            usdc: 0x1d17CBcF0D6D143135aE902365D2E5e2A16538D4,
            account: BURNER_WALLET
        });
    }

    function getOrCreateAnvilEthNetworkConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock erc20Mock = new ERC20Mock();
        vm.stopBroadcast();

        localNetworkConfig =
            NetworkConfig({entryPoint: address(entryPoint), usdc: address(erc20Mock), account: ANVIL_DEFAULT_ACCOUNT});

        return localNetworkConfig;
    }
}
