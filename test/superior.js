const Promise = require("bluebird");
web3.eth = Promise.promisifyAll(web3.eth);
const {toBN, toWei, utf8ToHex} = web3.utils;
const { constants,time,expectRevert } = require('openzeppelin-test-helpers');
const { shouldFail } = require("openzeppelin-test-helpers");
const SuperiorTransparentUpgradableProxy = artifacts.require("SuperiorTransparentUpgradableProxy");
const PokeToken = artifacts.require("PokeToken");
const PokeTokenV2 = artifacts.require("PokeTokenV2");
const { expect } = require('chai');
const chai = require('chai');

contract('SuperiorTransparentUpgradableProxy', (accounts) => {

    const [proxyAdminAddress, anotherAccount] = accounts;

    let proxy;
    let implementationV0,  implementationV1;

    before(async function () {
        implementationV0 = (await PokeToken.new()).address;   //poke +4
        implementationV1 = (await PokeTokenV2.new()).address; //poke +1
    });

    beforeEach(async function () {
        proxy = await SuperiorTransparentUpgradableProxy.new(implementationV0, {from: proxyAdminAddress});
    });

    it('should allow admin to upgrade contract before reaching minimum yes votes', async() =>
    {
        //after deploy, Admin executes upgradeTo to setup initial implementation
        const tx = await proxy.upgradeTo({from: proxyAdminAddress});
        
        //Instantiate poketoken and execute increatePoke function
        const pokeToken = new PokeToken(proxy.address);

        await pokeToken.increasePoke({from: anotherAccount});

        let value = await pokeToken.getPoke({from: anotherAccount});

        //value should be equal to 4 (one poke)
        assert.strictEqual(value.toString(10), '4', "Increase poke is not 4");

        //now admin will set upgrade implementation to poke version 2. it will increase poke in 1.
        await proxy.setUpgradeTo(implementationV1, 2000, {from: proxyAdminAddress});

        const tt = await proxy.vote(1, {from: anotherAccount});
        console.log(tt);

        await expectRevert
        (
            proxy.upgradeTo({from: anotherAccount}),
            "Yes votes didnt reach minimum required value."
        );
        await proxy.upgradeTo({from: proxyAdminAddress});  //admin can execute upgrade and doesn't need to wait for the minimum number of votes

        await pokeToken.increasePoke({from: anotherAccount});  //will add +1

        value = await pokeToken.getPoke({from: anotherAccount});
        
        assert.strictEqual(value.toString(10), '5', "Increase poke is not 5");
    });

});