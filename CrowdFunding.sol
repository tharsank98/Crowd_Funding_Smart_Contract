// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CrowdFunding{

    struct Request{
        string description;
        address payable recipient;
        uint value;
         bool completed;
         uint noOfVoters;
         mapping(address=>bool) voters;
    }

    mapping(address => uint) public contributors;
    mapping(uint => Request) public requests;
    uint public numRequests;

    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor (uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }

    modifier onlyManager{
        require (msg.sender== manager,"you are not the manager");
        _;
    }

    function CreateRequest(string calldata _description,address payable _recipient,uint _value) public onlyManager{
      Request storage newRequest=requests[numRequests];
      numRequests++;
      newRequest.description=_description;
      newRequest.recipient=_recipient;
      newRequest.value=_value;
      newRequest.completed=false;
      newRequest.noOfVoters=0;

      
    }

    function contribution() public payable{
        require(block.timestamp< deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum contribution is 100 wei");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        } 
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
     }

     function getContractBalance() public view returns(uint){
         return address(this ).balance;
     }

     function refund() public {
         require(block.timestamp>deadline && raisedAmount<target ,"You are not eligible for refund");
         require(contributors[msg.sender]>0 ,"You are not a contributor");
         payable(msg.sender).transfer(contributors[msg.sender]);
         contributors[msg.sender]=0;
     }

     function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You are not a contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have been Already voted");
        thisRequest.voters[msg.sender]=true; 
        thisRequest.noOfVoters++;
     }

     function makePayment(uint _requestNo) public onlyManager{
         require(raisedAmount > target,"Target is not reached");
          Request storage thisRequest=requests[_requestNo];
          require(thisRequest.completed==false,"This request has been already completed");
          require(thisRequest.noOfVoters>noOfContributors/2,"The majority does not support the request");
          thisRequest.recipient.transfer(thisRequest.value);
          thisRequest.completed=true;
     }


}