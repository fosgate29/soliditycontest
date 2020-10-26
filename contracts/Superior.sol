// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IERC20.sol";

contract Superior  {

    uint128 public totalYesVotes;
    uint128 public totalNoVotes;
    
    mapping(bytes32 => address) public hasVoted;
    
    IERC20 public ERC20Token;
    
    /*
    * [time stamp,#min votes, time stamp of vote completion, owner address]
    */
    uint128[] public voteDetails;
    
    constructor() {
        voteDetails.push(0); // # of votes
        voteDetails.push(0); // # timestamp
        voteDetails.push(0); // expiration
        voteDetails.push(1); // first deploy
    }

    function _startSetUpgradeTo(uint128 _minYesVotes, uint128 _expirationDays, address _erc20Token) internal  {
        require(voteDetails.length == 1, "Vote is already opened.");
        require(_minYesVotes > 1000, "Vote percent must be greater that 1000.");
        require(_expirationDays > 5 && _expirationDays < 13, "Expiration must be greater than 5 days and less than 13 days.");
        
        ERC20Token = IERC20(_erc20Token);
        
        totalYesVotes = 0;
        totalNoVotes = 0;
        
        voteDetails[0] = _minYesVotes; //  at least 1001 percent
        voteDetails.push(uint128(block.timestamp)); // # time when vote started
        voteDetails.push(_expirationDays); // in days
    }
    
    function generateVoteId() public view returns (bytes32 result){
        return keccak256(abi.encode(msg.sender, voteDetails[1]));
    }
    
    function vote(bool yes) external {
        require(voteDetails.length > 1, "Vote is not opened.");
        
        require( (voteDetails[1] + (voteDetails[1] * 1 days))  > uint128(block.timestamp) , "Vote time expired." );
        
        require(ERC20Token.balanceOf(msg.sender) > 0, "User does not have tokens to vote" );
        
        //check if user has already voted
        bytes32 voteId = generateVoteId();
        require(hasVoted[voteId] != msg.sender, "User has already voted");
        
        if(yes){
            totalYesVotes++;
        }
        else{
            totalNoVotes++;
        }
        
        hasVoted[voteId] = msg.sender;
    }
    
    function _resetVoteDetails() internal {
        uint128[] memory newVoteDetails = new uint128[](1);
        voteDetails = newVoteDetails;
    }
    
    function _checkUpgradeIsOk(bool isAdmin) internal {
        require(voteDetails.length > 1, "Upgrade is closed");
        
        if(isAdmin){
            //if it is first deploy, Admin can upgrade
            if(voteDetails.length==3){
                voteDetails.push();
            }
            
            require(voteDetails[3] == 1, "It isnt first deploy");
        }
        else {
            require(totalYesVotes > voteDetails[0], "Yes votes didnt reach minimum required value.");
        }
    }
    
}
