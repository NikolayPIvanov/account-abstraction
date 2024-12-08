// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract MinimalAccountTest is Test {
    HelperConfig public helperConfig;
    MinimalAccount public minimalAccount;

    function setUp() public {
        DeployMinimal deployMinimal = new DeployMinimal();

        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
    }
}
