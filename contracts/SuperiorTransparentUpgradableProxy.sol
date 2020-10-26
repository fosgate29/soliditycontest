// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./TransparentUpgradeableProxy.sol";


contract SuperiorTransparentUpgradableProxy is TransparentUpgradeableProxy {
    
    /*
    * [time stamp,#min votes, time stamp of vote completion, owner address]
    */
    uint128[] public voteDetails;
    uint128 public totalYesVotes;
    uint128 public totalNoVotes;
    
    address public newImplementationAddress;
    
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address _admin) payable TransparentUpgradeableProxy(_admin) {
        newImplementationAddress = _logic;
        voteDetails.push(0); // # of votes
        voteDetails.push(0); // # timestamp
        voteDetails.push(0); // expiration
        voteDetails.push(1); // first deploy
    }
    
    /**
     * @dev New implementation address
     * 
     * NOTE: Only the admin can call this function
     */
    function setUpgradeTo(address newImplementation, uint128 _votePercent, uint128 _expirationDays) external ifAdmin {
        require(voteDetails.length == 1, "Vote is already opened.");
        require(_votePercent > 50, "Vote percent must be greater that 50%.");
        require(_expirationDays > 2, "Expiration must be greater than 2 days.");
        
        newImplementationAddress = newImplementation;
        
        totalYesVotes = 0;
        totalNoVotes = 0;
        
        voteDetails[0] = _votePercent; //  at least 51 percent
        voteDetails.push(uint128(block.timestamp)); // # time when vote started
        voteDetails.push(_expirationDays); // in days
        
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo() external {
        require(voteDetails.length > 1, "Upgrade is closed");
        
        if(msg.sender == _admin()){
            //if it is first deploy, Admin can upgrade
            if(voteDetails.length==3){
                voteDetails.push();
            }
            
            require(voteDetails[3] == 1, "It isnt first deploy");
        }
        else {
            require(totalYesVotes > voteDetails[0], "Yes votes didnt reach minimum required value.");
        }
        
        _upgradeTo(newImplementationAddress);
        uint128[] memory newVoteDetails = new uint128[](1);
        voteDetails = newVoteDetails;
    }

}
