// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event List(string name, uint256 cost, uint256 stock);
    event Buy(address buyer, uint256 cost, uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //runs only once when the contract is deployed to the blockchain
    constructor() {
        owner = msg.sender;
    }

    //List products
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        //create Item struct using the paramters that are passed
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //save to blockchain
        items[_id] = item;

        //emit the event
        emit List(_name, _cost, _stock);
    }

    //buy product
    function buy(uint256 _id) public payable {
        //fetch item
        Item memory item = items[_id];

        //check if sender has enough ethers to carry out the transaction
        require(msg.value >= item.cost);
        //item should be in stock
        require(item.stock > 0);

        //create an order
        Order memory order = Order(block.timestamp, item);

        //add order for user
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //subtract the stock count
        items[_id].stock = item.stock - 1;

        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    //withdraw function
    function withdraw() public onlyOwner {
        //this: address of this smart contract
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
