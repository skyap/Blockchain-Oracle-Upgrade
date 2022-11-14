const Oracle = artifacts.require("Oracle");

contract("Oracle",accounts=>{
    let oracle;
    beforeEach(async ()=>{
        oracle=await Oracle.deployed();
    });

    // it("", async function(){
    // });

    it("account[0] cannot become oracle", async ()=>{
        let addError;
        try{
            await oracle.createOracle(web3.utils.asciiToHex("1"),accounts[0],"hello world");
        }
        catch (error){
            addError = error;
        }
        assert.notEqual(addError,undefined,"Error must be thrown");
    });

    it("create 5 oracle", async ()=>{
        const names = ["alpha","beta","gamma","delta","epsilon","zeta","eta","theta","lota"];
        const apis = ["abc.com","def.com","ghi.com","jkl.com","mno.com","pqr.com"];
        for(let i=1;i<6;i++){
            await oracle.createOracle(web3.utils.asciiToHex(names[i-1]),accounts[i],apis[i-1]);
        }
        let result = await oracle.getOraclersSet();
        // console.log(result);
        assert.equal(result.length,5);
        for(let i=0;i<5;i++){
            assert.equal(web3.utils.toUtf8(result[i].name),names[i]);
            assert.equal(result[i].owner,accounts[i+1]);
            assert.equal(result[i].api,apis[i]);
        }
        // console.log(web3.utils.toUtf8(r2[0].name));
    });

    it("Cannot re-register oracler from same account", async ()=>{
        let addError;
        try{
            await oracle.createOracle(web3.utils.asciiToHex("test"),accounts[1],"abc.com");
        }
        catch (error){
            addError = error;
        }
        assert.notEqual(addError,undefined,"Error must be thrown");
    });    

    // it("", async function(){
    // });

    // it("", async function(){
    // });

    // it("", async function(){
    // });












    // it("create oracle and read its value 2", async function(){
    //     let r2 = await oracle.oraclersSet([0]);
    //     console.log(r2.balance.toString());
    // });

});


