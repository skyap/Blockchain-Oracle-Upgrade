// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;
import "./Oracle.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "./AccessControl.sol";

contract Request is AccessControl {
    Oracle oracle;
    address oracleManager;
    uint256 nextRequestId;
    uint256[] private requestsMappingIndex;
    uint256 registeredOraclers;
    
    // uint256 public payment;
    
    constructor(address _deployedOracle){
        _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
        _setupRole(ORACLE_MANAGER_ROLE,msg.sender);
        oracle = Oracle(_deployedOracle);
        // 100gwei
        // payment = 100000000000 wei;
    }
    
    // function changePayment(uint256 p){
    //     require(hasRole(DEFAULT_ADMIN_ROLE,msg.sender),"Only admin can change payment");
    //     payment = p;
    // }

    //Request struct for holding the object
    struct Requests {
        uint256 requestId;
        uint256 arrivalTime;
        address sender;
        bool isPending;
        bytes32 query;
        address[] oraclers;
        uint256[] stakes;
        uint8 flag;
    }

    // Event for creation of a request
    event requestCreated(
        uint256 indexed requestId,
        bytes32 indexed barcode,
        address indexed sender
    );
    //Event for assiging oracles to request
    event oraclersToRequestAssigned(
        uint256 requestId,
        address[] oraclerAddress,
        address[] from,
        address[] to,
        uint256[] value
    );
    // event transferOraclerBond(address[] from, address[] to, uint256[] value);

    mapping(uint256 => Requests) public requests;
    Requests[] public requestSet;
    Requests[] public finishedRequestsSet;

    //Set the manager oracle address
    // function setOraclerManagerAddress() public {
    //     oracleManager = oracle.getOracleManagerAddress();
    // }

    //Get the manager oracle address
    // function getOraclerManagerAddress() public view returns (address) {
    //     return oracleManager;
    // }

    //Get the registered oracles number
    // function countRegisteredOraclers() public view returns (uint256) {
    //     return oracle.getCountRegisteredOraclers();
    // }

    //Initialize the oracle contract address
    function accessDeployedOracleContract(address _deployedOracle)
        public
        returns (bool)
    {   require(!hasRole(DEFAULT_ADMIN_ROLE,msg.sender),"Only admin can set oracle address");
        oracle = Oracle(_deployedOracle);
        oracleManager = _deployedOracle;
        // setOraclerManagerAddress();
        return true;
    }

    //Get a request either pending/non-pending
    function activeRequests(uint256 _requestId)
        public
        view
        returns (
            uint256 requestId,
            uint256 arrivalTime,
            address sender,
            bool isPending,
            bytes32 query,
            address[] memory oraclers,
            uint256[] memory stakes
        )
    {
        require(
            isRequestCreated(_requestId) == true,
            "There is no request with the specified id."
        );
        return (
            requestSet[_requestId].requestId,
            requestSet[_requestId].arrivalTime,
            requestSet[_requestId].sender,
            requestSet[_requestId].isPending,
            requestSet[_requestId].query,
            requestSet[_requestId].oraclers,
            requestSet[_requestId].stakes
        );
    }

    //Pass a string request for fetching information
    function createRequest(bytes32 barcode)
        public payable
        returns (uint256 _requestId)
    {
        Requests memory _request = requests[nextRequestId];
        _request.arrivalTime = block.timestamp;
        _request.requestId = nextRequestId;
        _request.isPending = true;
        _request.query = barcode;
        _request.sender = msg.sender;
        _request.flag = 1;
        
        requestsMappingIndex.push(nextRequestId);
        nextRequestId++;
        requestSet.push(_request);
        emit requestCreated(_request.requestId, barcode, msg.sender);
        return _request.requestId;
    }

    //Check the requestId exists
    //  
    function isRequestCreated(uint256 requestId)
        public
        view
        returns (bool value)
    {
        // value = false;
        // if (requestSet.length > 0) {
        //     for (uint256 i = 0; i < requestSet.length; i++) {
        //         Requests storage _request = requestSet[i];
        //         if (_request.requestId == requestId) {
        //             value = true;
        //             break;
        //         }
        //     }
        // }
        // return value;
        if (requestSet[requestId].flag == 1) return true;
        return false;
    }

    //Return the median oracle popularity for oracle selection
    // function getMedianOraclerPopularity() public view returns (uint256) {
    //     return oracle.getMedianOracler();
    // }

    //Assign oraclers to requests for fetching information
    //Index zero belongs to the oraceler manager
    function assignOraclersToRequest(uint256 requestId) public {
        uint256 countOraclers = oracle.getCountRegisteredOraclers();
        uint256 stakeThreshold = oracle.getStakeThreshold();
        address[] memory from = new address[](countOraclers);
        address[] memory to = new address[](countOraclers);
        uint256[] memory values = new uint256[](countOraclers);
        // address _oraclerManager = getOraclerManagerAddress();
        uint256 index;

        require(countOraclers > 0, "There are no registered oracles.");
        require(isRequestCreated(requestId) == true, "Request does not exist.");
        uint256 _popularity = oracle.getMedianOracler();
        for (uint256 i = 1; i < countOraclers; i++) {
            uint256 _oraclerPopularity = oracle.getOraclerPopularity(i);
            if (_oraclerPopularity >= _popularity) {
                address _oracler = oracle.getOraclerAddress(i);
                oracle.increaseOraclerBalance(
                    oracleManager,
                    stakeThreshold
                );
                oracle.decreaseOraclerBalance(_oracler, stakeThreshold);
                requestSet[requestId].oraclers.push(_oracler);
                requestSet[requestId].stakes.push(stakeThreshold);
                to[index] = oracleManager;
                from[index] = _oracler;
                values[index] = stakeThreshold;
                index++;
            }
        }

        emit oraclersToRequestAssigned(
            requestId,
            requestSet[requestId].oraclers,
            from,
            to,
            values
        );
    }

    //Return the number of submitted requests
    function countSubmittedRequests() public view returns (uint256) {
        return requestSet.length;
    }

    //Return the request query
    function getRequestQuery(uint256 requestId) public view returns (bytes32) {
        return requestSet[requestId].query;
    }

    //Get the stake per request
    function getRequestStakes(uint256 requestId)
        public
        view
        returns (uint256[] memory stakes)
    {
        return requestSet[requestId].stakes;
    }
}
