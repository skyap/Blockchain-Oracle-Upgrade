// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;
import "./Request.sol";
import "./AccessControl.sol";

contract Oracle is AccessControl{
    
    // event Received(address, uint);
    // receive() external payable {
    //     emit Received(msg.sender, msg.value);
    // }
    // function getBalance() public view returns (uint256){
    //     return address(this).balance;
    // }
    // function sendAllBalance() public payable{
    //     payable(msg.sender).transfer(address(this).balance);
    // }
    
    
   
    uint256 private stakeThreshold;
    uint256 private countOraclers;
    uint256 private nextOraclerId;
    uint256 private nextRequestId;
    uint256 private nextResponseId;

    function setStakeThreshold(uint256 value) public {
        stakeThreshold = value;
    }


    function getStakeThreshold() public view returns (uint256 value) {
        return stakeThreshold;
    }


    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
        _setupRole(ORACLE_MANAGER_ROLE,msg.sender);
        stakeThreshold = 1000000000000000000 wei;
    }

    //Oracle struct for the oracle object
    struct Oraclers {
        bytes32 name;
        address owner;
        string api;
        uint256 popularity;
        uint256 numericPopularity;
        bool registered; //activate or deactivate
        uint256 balance;
        uint256 oraclerId;
        bool created; //created or not created
    }

    // mapping(uint256 => Oraclers) public oraclers;
    mapping(address => Oraclers) private oraclers;
    // Oraclers[] private oraclersSet;
    // Oraclers[] private unregisteredOraclersSet;
    // address[] private oraclersAddress;

    // Getter function
    function getOraclersSet() public view returns(Oraclers[] memory){
        return oraclersSet;
    }


    //Event for creation of an oracle
    event oracleIsCreated(address indexed oracler, uint256 indexed oraclerId);
    //Event for unregistering an oracle
    event oracleIsUnregistered(address indexed oracler, uint256 oraclerId);
    //Event for deactivation of an oracle
    event oracleIsDeactivated(address indexed oracler, bool result);
    //Event for activeation of an oracle
    event oracleIsActivated(address indexed oracler, bool result);
    //Event for deletion of an oracle
    event oracleIsDeleted(address indexed oracler, bool result);
    //Event for oracle popularity changes
    event oraclePopularityIsChanged(address indexed oracler, uint256 value);
    //Event for changing the oracle name
    event oracleNameIsChanged(address indexed oraclerAddress, bytes32 value);

  


    //Create oraclers for fetching information
    function createOracle(bytes32 name, address owner,string memory api) public {
        require(!hasRole(DEFAULT_ADMIN_ROLE,owner),"Admin cannot be an Oracle");
        require(!hasRole(ORACLE_MANAGER_ROLE,owner),"Oracle Manager cannot be an Oracle");
        require(oraclers[owner].created == false,"Oraclers are not allowed to re-created again.");
        require(owner.balance > 0, "Oraclers must have a non-zero balance.");
        require(owner.balance - (stakeThreshold) > 0,"Oraclers balance cannot be negative.");
        
        Oraclers memory oracle = Oraclers(name, owner,api, 0, 0, true, owner.balance, nextOraclerId,true);
            
        oraclers[owner] = oracle;
        nextOraclerId++;

        // oraclersSet.push(oracle);
        // oraclersAddress.push(owner);

        setCountRegisteredOraclers(oraclersSet.length);

        emit oracleIsCreated(owner, oracle.oraclerId);
    }



    //Index 0 belongs to the manager
    //Change a registered oracler status
    function deactivateOraclers(address oraclerAddress) public{
        // require(oraclersSet.length > 1, "There are no registered oraclers.");
        // require(isOraclerActive(oraclerAddress) == true,"Oracler is already unregistered.");
        require(hasRole(ORACLE_MANAGER_ROLE,msg.sender),"Oracler manager has only the permission.");
        require(oraclers[owner].registered==false,"Oracler is already unregistered");
        oraclersSet[i].registered = false;
        emit oracleIsDeactivated(oraclerAddress,true);
        // for (uint256 i = 1; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oraclerAddress) {
        //         oraclersSet[i].registered = false;
        //         unregisteredOraclersSet.push(oraclersSet[i]);
        //         Oraclers memory _oracler = oraclers[i];
        //         Oraclers memory _oracler = oraclers[oraclerAddress];
        //         _oracler.registered = false;
        //         setCountRegisteredOraclers(oraclersSet.length - 1);
        //         emit oracleIsDeactivated(oraclerAddress, true);
        //         return 1;
        //     }
        // }
        // emit oracleIsDeactivated(oraclerAddress, false);
        // return 0;
    }

    //Index 0 belogns to the manager
    //Activate an inactive oracler
    function activateOraclers(address oraclerAddress)public returns (uint256 reply){
        require(hasRole(ORACLE_MANAGER_ROLE,msg.sender),"Oracler manager has only the permission.");
        // require(oraclersSet.length > 1, "There are no registered oraclers.");
        require(oraclers[owner].registered == true,"Oracler already activated.");
        oraclers[oraclerAddress].registered = true;
        emit oracleIsActivated(oraclerAddress,true);
        // for (uint256 i = 1; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oraclerAddress) {
        //         oraclersSet[i].registered = true;
        //         unregisteredOraclersSet.push(oraclersSet[i]);

        //         Oraclers memory _oracler = oraclers[oraclerAddress];
        //         _oracler.registered = true;
        //         setCountRegisteredOraclers(oraclersSet.length + 1);
        //         emit oracleIsActivated(oraclerAddress, true);
        //         return 1;
        //     }
        // }
        // emit oracleIsActivated(oraclerAddress, false);
        // return 0;
    }

    //Only unregistered oracle can be delete
    function deleteOraclers(address oraclerAddress) public returns (uint256 _reply){
        require(hasRole(ORACLE_MANAGER_ROLE,msg.sender),"Oracler manager has only the permission.");
        // require(oraclersSet.length > 1, "There are no registered oraclers.");
        require(oraclers[owner].created == true,"Oracler not exist.");
        delete oraclers[oraclerAddress];
        emit oracleIsDeleted(oraclerAddress,true);
        // for (uint256 i = 1; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oraclerAddress) {
        //         delete oraclersSet[i];
        //         delete oraclers[oraclerAddress];
        //         emit oracleIsDeleted(oraclerAddress, true);
        //         setCountRegisteredOraclers(oraclersSet.length - 1);
        //         return 1;
        //     }
        // }
        // emit oracleIsActivated(oraclerAddress, false);
        // return 0;
    }

    //Index 0 belongs to manager
    //Change an oracle popularity
    function changeOraclerPopularity(address oraclerAddress,uint256 index,uint256 value,uint256 numericValue) public{
        require(value <= 100, "Popularity must be in the range of [0,100].");
        // require(oraclersSet.length > 1, "There are no registered oraclers.");
        require(oraclers[owner].created == true,"Oracler not exist.");
        require(oraclers[owner].registered==true,"Oracler is active.");

        // oraclersSet[index].popularity = value;
        // oraclersSet[index].numericPopularity = numericValue;

        // Oraclers memory _oracler = oraclers[oraclersSet[index].owner];
        // _oracler.popularity = value;
        // _oracler.numericPopularity = numericValue;

        oraclers[oraclerAddress].popularity = value;
        oraclers[oraclerAddress].numericPopularity = numericValue;

        emit oraclePopularityIsChanged(oraclerAddress, numericValue);
        // return true;
    }
    /////////////////////////////////////////////////////////////////////////////////////////
    //Index 0 belongs to manager
    //Change an oracle balance
    function increaseOraclerBalance(address oraclerAddress, uint256 value) public {
        require(oraclers[owner].created == true,"Oracler not exist.");
        oraclers[oraclerAddress].balance += value;
        // for (uint256 i = 0; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oraclerAddress) {
        //         oraclersSet[i].balance += value;
        //         Oraclers memory _oracler = oraclers[oraclerAddress];
        //         _oracler.balance += value;
        //         return true;
        //     }
        // }
        // return false;
    }

    //Index 0 belongs to manager
    //Change an oracle popularity
    function decreaseOraclerBalance(address oraclerAddress, uint256 value) public {
        require(oraclers[owner].created == true,"Oracler not exist.");
        oraclers[oraclerAddress].balance -= value;
        require(value >= 0, "Balance cannot be negative.");
        // for (uint256 i = 0; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oraclerAddress) {
        //         oraclersSet[i].balance -= value;
        //         Oraclers memory _oracler = oraclers[oraclerAddress];
        //         _oracler.balance = oraclersSet[i].balance;
        //         return true;
        //     }
        // }
        // return false;
    }


    function getOraclerPopularity(uint256 _index) public view returns (uint256 _popularity){
        return oraclersSet[_index].popularity;
    }

    //Get the oracle numeric popularity
    function getOraclerNumericPopularity(uint256 _index) public view returns (uint256 _popularity){
        return oraclersSet[_index].numericPopularity;
    }

    //Get the oracler address by index from the set
    function getOraclerAddress(uint256 _index)public view returns (address _address){
        return oraclersSet[_index].owner;
    }

    function getOraclerId(uint256 _index) public view returns (uint256 _id) {
        return oraclersSet[_index].oraclerId;
    }


    //Set the number of registered oraclers either active or deactive
    function setCountRegisteredOraclers(uint256 oraclersLength) private {
        countOraclers = oraclersLength;
    }

    //Get the number of registered oraclers
    function getCountRegisteredOraclers() public view returns (uint256) {
        return countOraclers;
    }

    //Get an oracle index from the set by the address
    function getOraclerIndex(address oracleAddress) public view returns (uint256) {
        return oraclers[oracleAddress].oraclerId;
        // uint256 oraclerId = 0;
        // for (uint256 i = 0; i < oraclersSet.length; i++) {
        //     if (oraclersSet[i].owner == oracleAddress) {
        //         oraclerId = i;
        //         break;
        //     }
        // }
        // return oraclerId;
    }

    //Get registered oraclers either ative/deactive
    function registeredOraclers(uint256[] memory index) public view returns (
            // bytes32
            bytes32[] memory name,
            address[] memory owners,
            uint256[] memory popularity,
            bool[] memory registered,
            uint256[] memory balance,
            uint256[] memory oraclerIds
        )
    {
        bytes32[] memory _name = new bytes32[](index.length);
        address[] memory _owners = new address[](index.length);
        uint256[] memory _popularity = new uint256[](index.length);
        bool[] memory _registered = new bool[](index.length);
        uint256[] memory _balance = new uint256[](index.length);
        uint256[] memory _ids = new uint256[](index.length);

        for (uint256 i = 0; i < oraclersSet.length; i++) {
            _name[i] = oraclersSet[i].name;
            _owners[i] = oraclersSet[i].owner;
            _popularity[i] = oraclersSet[i].popularity;
            _registered[i] = oraclersSet[i].registered;
            _balance[i] = oraclersSet[i].balance;
            _ids[i] = oraclersSet[i].oraclerId;
        }
        // return _name[0];
        return (_name, _owners, _popularity, _registered, _balance, _ids);
    }

    
    function isRegistered(address _sender) public view returns (bool){
        return oraclers[_sender].registered;
    }

    //Excluding oracler manager and sort existing ones
    //based on their popularity
    function sortOraclers(Oraclers[] memory _oraclers)
        private
        pure
        returns (Oraclers[] memory sortedOraclers)
    {
        for (uint256 i = 1; i < _oraclers.length; i++) {
            for (uint256 j = i + 1; j < _oraclers.length; j++) {
                if (_oraclers[i].popularity > _oraclers[j].popularity) {
                    Oraclers memory tempOracler = _oraclers[i];
                    _oraclers[i] = _oraclers[j];
                    _oraclers[j] = tempOracler;
                }
            }
        }
        return _oraclers;
    }

    //Excluding oracler manager and sort existing ones
    //based on their popularity
    //An external function
    function sortOracler(uint256[] memory index)
        public
        view
        returns (
            bytes32[] memory name,
            address[] memory owners,
            uint256[] memory popularity,
            bool[] memory registered,
            uint256[] memory balance,
            uint256[] memory oraclerIds
        )
    {
        bytes32[] memory _name = new bytes32[](index.length);
        address[] memory _owners = new address[](index.length);
        uint256[] memory _popularity = new uint256[](index.length);
        uint256[] memory _numPopularity = new uint256[](index.length);
        bool[] memory _registered = new bool[](index.length);
        uint256[] memory _balance = new uint256[](index.length);
        uint256[] memory _ids = new uint256[](index.length);

        Oraclers[] memory _oraclers = oraclersSet;

        for (uint256 i = 1; i < _oraclers.length; i++) {
            for (uint256 j = i + 1; j < _oraclers.length; j++) {
                if (_oraclers[i].popularity > _oraclers[j].popularity) {
                    Oraclers memory tempOracler = _oraclers[i];
                    _oraclers[i] = _oraclers[j];
                    _oraclers[j] = tempOracler;
                }
            }
        }
        for (uint256 i = 0; i < _oraclers.length; i++) {
            _name[i] = _oraclers[i].name;
            _owners[i] = _oraclers[i].owner;
            _popularity[i] = _oraclers[i].popularity;
            _numPopularity[i] = _oraclers[i].numericPopularity;
            _registered[i] = _oraclers[i].registered;
            _balance[i] = _oraclers[i].balance;
            _ids[i] = _oraclers[i].oraclerId;
        }
        return (_name, _owners, _popularity, _registered, _balance, _ids);
    }

    //Oracler manager resides at index zero
    function getOraclersMedian(uint256 _sortedOraclersIndex)
        public
        view
        returns (
            bytes32 name,
            address owners,
            uint256 popularity,
            bool registered,
            uint256 balance,
            uint256 id
        )
    {
        require(_sortedOraclersIndex > 1, "There are no registered oraclers");
        Oraclers[] memory _oraclersSet = sortOraclers(oraclersSet);
        uint256 value = (_sortedOraclersIndex) % 2;
        uint256 _median = (_sortedOraclersIndex) / 2;
        if (value != 0) {
            _median = _median + 1;
        }
        bytes32 _name = _oraclersSet[_median].name;
        address _owner = _oraclersSet[_median].owner;
        uint256 _popularity = _oraclersSet[_median].popularity;
        if (value != 0) {
            _popularity =
                (_oraclersSet[_median - 1].popularity + _popularity) /
                2;
        }
        bool _registered = _oraclersSet[_median].registered;
        uint256 _balance = _oraclersSet[_median].balance;
        uint256 _id = _oraclersSet[_median].oraclerId;
        return (_name, _owner, _popularity, _registered, _balance, _id);
    }

    function getMedianOracler() public view returns (uint256 popularity) {
        (, , uint256 _popularity, , , ) = getOraclersMedian(oraclersSet.length);
        return (_popularity);
    }

    //Oracler manager resides at index zero
    // function transferStake(address fromOracler, uint256 value) public payable {
    //     require(fromOracler.balance > value, "Insufficient fund.");
    //     Oraclers memory oracler = oraclers[fromOracler];
    //     Oraclers memory manager = oraclers[oracleManager];
    //     oracler.balance -= value;
    //     manager.balance += value;
    // }
    function transferStake()public payable{
        
    }

    /////////////////////////////////////////////////////////////////////////////////////////
    //Return the corresponding index of an oracler
    function oraclerMappingIndex(address oracler)
        public
        view
        returns (uint256 index)
    {
        Oraclers memory _oracle = oraclers[oracler];
        return _oracle.oraclerId;
    }

    //Return the list of registered oraclers
    function getRegisteredOraclersAddress()
        public
        view
        returns (address[] memory _oracles)
    {
        return oraclersAddress;
    }
}
