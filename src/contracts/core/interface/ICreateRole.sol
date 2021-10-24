pragma solidity ^0.5.4;

interface IRoleTemplate{

   function createRole(address _owner) external  returns (uint256);

   function createRoles(address _owner) external  returns (uint256[]);

   event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

   event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

   function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

   function approve(address _approved, uint256 _tokenId) external payable;


}