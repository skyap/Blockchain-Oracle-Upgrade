var oracle = artifacts.require("Oracle");
var request = artifacts.require("Request");
var response = artifacts.require("Response");

module.exports = async function(deployer){
    await deployer.deploy(oracle);
    const o = await oracle.deployed();
    await deployer.deploy(request,o.address);
    const r = await request.deployed();
    await deployer.deploy(response,o.address,r.address);    
}