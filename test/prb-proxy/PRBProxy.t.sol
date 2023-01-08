// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { PRBProxy } from "src/PRBProxy.sol";

import { BaseTest } from "../BaseTest.t.sol";
import { TargetChangeOwner } from "../helpers/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "../helpers/targets/TargetDummy.t.sol";
import { TargetEcho } from "../helpers/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../helpers/targets/TargetMinGasReserve.t.sol";
import { TargetPanic } from "../helpers/targets/TargetPanic.t.sol";
import { TargetRevert } from "../helpers/targets/TargetRevert.t.sol";
import { TargetSelfDestruct } from "../helpers/targets/TargetSelfDestruct.t.sol";

contract PRBProxy_Test is BaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Targets {
        TargetChangeOwner changeOwner;
        TargetDummy dummy;
        TargetEcho echo;
        TargetMinGasReserve minGasReserve;
        TargetPanic panic;
        TargetRevert revert;
        TargetSelfDestruct selfDestruct;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event Execute(address indexed target, bytes data, bytes response);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    PRBProxy internal proxy;
    Targets internal targets;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        BaseTest.setUp();

        proxy = new PRBProxy();
        targets = Targets({
            changeOwner: new TargetChangeOwner(),
            dummy: new TargetDummy(),
            echo: new TargetEcho(),
            minGasReserve: new TargetMinGasReserve(),
            panic: new TargetPanic(),
            revert: new TargetRevert(),
            selfDestruct: new TargetSelfDestruct()
        });
    }
}