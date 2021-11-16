pragma solidity ^0.4.20;

interface ITRC721 {
    // Returns the number of NFTs owned by the given account
    function balanceOf(address _owner) external view returns (uint256);

    //Returns the owner of the given NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    //Transfer ownership of NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    //Transfer ownership of NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    //Transfer ownership of NFT
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    //Grants address ‘_approved’ the authorization of the NFT ‘_tokenId’
    function approve(address _approved, uint256 _tokenId) external payable;

    //Grant/recover all NFTs’ authorization of the ‘_operator’
    function setApprovalForAll(address _operator, bool _approved) external;

    //Query the authorized address of NFT
    function getApproved(uint256 _tokenId) external view returns (address);

    //Query whether the ‘_operator’ is the authorized address of the ‘_owner’
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    //The successful ‘transferFrom’ and ‘safeTransferFrom’ will trigger the ‘Transfer’ Event
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    //The successful ‘Approval’ will trigger the ‘Approval’ event
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    //The successful ‘setApprovalForAll’ will trigger the ‘ApprovalForAll’ event
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

}

interface TRC165 {
    //Query whether the interface ‘interfaceID’  is supported
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}