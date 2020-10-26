// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./TransparentUpgradeableProxy.sol";
import "./Superior.sol";


contract SuperiorTransparentUpgradableProxy is TransparentUpgradeableProxy, Superior {
    
    address public newImplementationAddress;
    
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic) payable TransparentUpgradeableProxy(msg.sender) {
        newImplementationAddress = _logic;
    }
    
    /**
     * @dev New implementation address
     * 
     * NOTE: Only the admin can call this function
     */
    function setUpgradeTo(address _newImplementation, uint128 _votePercent, uint128 _expirationDays, address _erc20Token) external ifAdmin {
        //initialize vote details
        _startSetUpgradeTo(_votePercent, _expirationDays, _erc20Token);
        
        newImplementationAddress = _newImplementation;
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo() external {
        //it will revert if upgrade is not allowed
        _checkUpgradeIsOk(msg.sender == _admin());
        
        _upgradeTo(newImplementationAddress);
        
        //reset vote details because vote is ended
        _resetVoteDetails();
    }
    
  

}
