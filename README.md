# Superior Proxy

It will explore this bug:
https://solidity.ethereum.org/2020/10/07/solidity-dynamic-array-cleanup-bug/

## Details

We downloaded OpenZepplin proxy implementation that was using solidity ^0.7.0 and reused its code. Here is the link: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v3.2.1-solc-0.7/contracts/proxy 

We did only small changes in the code from OpenZepplin. And we created new 2 files:
Superior.sol and SuperiorTransparentUpgradableProxy. And our main contract is called PokeToken. It is very simple. It just increments by 1 a variable and it implements IER20 interface that has only one function: `balanceOf` (it is always returnin 10 for tests purposes).

Openzeppelin Proxy code is centralized. Admin can upgrade proxy implementation at anytime. So we decided to improve it and add a vote mechanism that will prevent a centralized decision.

To be able to upgrade we added a vote system. And it is very democratic. If you have a token in the ERC20, you can vote. It doesn't matter if you are holding a lot of tokens, you can only vote once. Of course you can split your tokens in a bunch of address. It is up to you to spend a lot of money in fees. We fixed a minimum value of 1.000 yes votes to be able to upgrade. This number can can change. Admin can get put it higher. But it should be at least 1.000. And after 7 days, vote period expires and anyone can reset vote process. Admin would need to start over again.

And if it has 1.000 votes, anyone can execute `upgradeTo` function. 

But Admin can executes it at anytime. It seems that Admin cannot do it, but because of the bug listed above, Admin can.

We created an array called `voteDetails`. It has 4 itens when smart contract is deployed. Last position holds 1. It is a check to let `upgradeTo` function that it is the first deploy and Admin can execute this function and doen't need to check votes. After executing `upgradeTo` for the first time, `voteDetails` array is resized to 1. It is how code detect that it was already deployed.

Now Admin wants to upgrade the code. It is ERC20 and we didn't reused OpenZeppelin ERC20 implementation and decimals are 17, causing some issues when users are checking their tokens in Etherscan. They complained and wants to upgrade it. So, Admin will execute `setUpgradeTo`




