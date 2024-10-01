// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract WATCHAIN {
    struct watch{
        address prod;string serial;
    }
    event mint_event(watch indexed  watchinstance,address indexed  owner,string msg);
    event transfer_event(address indexed  sender, address  indexed receiver,watch indexed watchinstance,string msg);
    event allow(address indexed prod, address val,string msg);
    event change_evt( watch indexed watchinstance,address indexed n_own,string msg);
    event deny(address indexed  prod, address indexed val,string msg);
    event rprt(watch indexed  watchinstance,string rep);
    event fees_change(uint256 mint_fee,uint256 transfer_fee,uint256 allow_fee,uint256 deny_fee,uint256 forced_fee,string smg_fees_ch);
    mapping (address=>mapping (string=>address)) public property;
    mapping (address=>mapping (address=>bool)) public allowance_vals;
    mapping (address=>mapping (string=>bool)) public mints;
    mapping (address=>uint256) public serial_counts;
    uint256 mint_fee;
    uint256 transfer_fee;
    uint256 allow_fee;
    uint256 official_msg_fee;
    uint256 deny_fee;
    address payable minter;
    function forced_change(string calldata serial,address owner,address prod,string calldata msg_force) public payable {
        require(allowance_vals[prod][msg.sender]==true || prod==msg.sender,"you are not a right validator or the right producer");
        property[prod][serial]=owner;
        emit  change_evt(watch(prod,serial), owner, msg_force);
    }//torun
    function mint(string calldata serial,address owner,string calldata msg_mint) public payable {
        require(msg.value>=mint_fee,"You must pay almost base mint fee");
        require(mints[msg.sender][serial]!=true,"Already minted");
        if(!mints[msg.sender][serial]){
            serial_counts[msg.sender]+=1;
            mints[msg.sender][serial]=true;
            property[msg.sender][serial]=owner;
            emit mint_event(watch(msg.sender,serial),owner,msg_mint);
        }
    }
    constructor(uint256 m_fee,uint256 t_fee,uint256 a_fee,uint256 d_fee,uint256 ofmsg_fee){
        minter=payable(msg.sender);
        mint_fee=m_fee;
        transfer_fee=t_fee;
        allow_fee=a_fee;
        official_msg_fee=ofmsg_fee;
        deny_fee=d_fee;
        emit fees_change(mint_fee, transfer_fee, allow_fee,deny_fee, official_msg_fee,"mint");
    }
    function change_fees(uint256 m_fee,uint256 t_fee,uint256 a_fee,uint256 d_fee,uint256 ofmsg_fee,string calldata msg_f_c) public{
        require(msg.sender==minter,"You are not minter account");
        mint_fee=m_fee;
        transfer_fee=t_fee;
        allow_fee=a_fee;
        official_msg_fee=ofmsg_fee;
        deny_fee=d_fee;
        emit fees_change(mint_fee, transfer_fee, allow_fee,deny_fee, official_msg_fee,msg_f_c);
    }
    function widthdrawal(uint256 amount) public {
        require(msg.sender==minter,"You must be the owner of contract to widthdrawal ether");
        require(address (this).balance>amount,"Contract cannot transfer this amount");
        minter.transfer(amount);
    }
    function transfer(string calldata serial,address receiever,address prod,string calldata msg_trasnfer) public payable {
        require(msg.value>=transfer_fee,"You must pay almost base transfer fee");
        require(receiever!=msg.sender,"You cannot send to yourself a watch guarantee");
        require(mints[prod][serial]==true,"Watch not minted");
        require(property[prod][serial]==msg.sender,"you are not owner");
        property[prod][serial]=receiever;
        emit transfer_event(msg.sender, receiever,watch(prod,serial), msg_trasnfer);
    }
    function check_p(address prod,string calldata serial) public view returns (address){
        return property[prod][serial];
    }
    function allow_validator(address validator,string calldata msg_allow) public payable {
        require(msg.value>=allow_fee,"You must pay almost base allow fee");
        require(validator!=msg.sender,"you cannot allow yourself");
        allowance_vals[msg.sender][validator]=true;
        emit allow(msg.sender, validator, msg_allow);
    }
    function deny_validator(address validator,string calldata msg_deny) public payable {
        require(msg.value>=deny_fee,"You must pay almost base deny fee");
        require(validator!=msg.sender,"you cannot deny allowance yourself");
        allowance_vals[msg.sender][validator]=false;
        emit deny(msg.sender, validator, msg_deny);
    }
    function report(string calldata mesg,string calldata serial,address prod) public payable {
        bool val=allowance_vals[prod][msg.sender] && msg.value>official_msg_fee;
        require(val || !allowance_vals[prod][msg.sender] || prod==msg.sender,"If you are validator you must pay for official msg");
        emit rprt(watch(prod,serial), mesg);
    }
}