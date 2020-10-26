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

    const [proxyAdminAddress, anotherAccount, anotherAccount1] = accounts;

    let proxy;
    let implementationV0,  implementationV1;

    before(async function () {
        implementationV0 = (await PokeToken.new()).address;
        implementationV1 = (await PokeTokenV2.new()).address;
    });

    beforeEach(async function () {
        const initializeData = Buffer.from('');
        proxy = await SuperiorTransparentUpgradableProxy.new(implementationV0, {
          from: proxyAdminAddress,
        });
    });

    it('should allow to run complete scenario', async() =>
    {
        const tx = await proxy.upgradeTo({from: proxyAdminAddress});

        const pokeToken = new PokeToken(proxy.address);

        await pokeToken.increasePoke({from: anotherAccount});

        const value = await pokeToken.getPoke({from: anotherAccount});

        console.log(value.toString(10));
        assert.strictEqual('4', value.toString(10), "Increase poke is not 4");

        const tx2 = await proxy.setUpgradeTo(implementationV1, 2000, 6, proxy.address, {from: proxyAdminAddress});      
        const tx3 = await proxy.upgradeTo({from: proxyAdminAddress});

        await pokeToken.increasePoke({from: anotherAccount});

        const value2 = await pokeToken.getPoke({from: anotherAccount});
        console.log(value2.toString(10));
        
        
    });

});