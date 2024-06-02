// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract SocialNetwork {
    struct User {
        address userAddress;
        string username;
        uint256 registrationTime;
    }

    struct Post {
        uint256 postId;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    uint256 public postCount;
    mapping(address => User) public users;
    mapping(uint256 => Post) public posts;
    mapping(uint256 => mapping(address => bool)) public postLikes;

    event UserRegistered(address indexed userAddress, string username, uint256 registrationTime);
    event PostCreated(uint256 indexed postId, address indexed author, string content, uint256 timestamp);
    event PostLiked(uint256 indexed postId, address indexed user);

    modifier onlyRegisteredUser() {
        require(bytes(users[msg.sender].username).length > 0, "You must be a registered user.");
        _;
    }

    function registerUser(string memory _username) external {
        require(bytes(_username).length > 0, "Username cannot be empty.");
        require(bytes(users[msg.sender].username).length == 0, "User already registered.");

        users[msg.sender] = User({
            userAddress: msg.sender,
            username: _username,
            registrationTime: block.timestamp
        });

        emit UserRegistered(msg.sender, _username, block.timestamp);
    }

    function createPost(string memory _content) external onlyRegisteredUser {
        require(bytes(_content).length > 0, "Post content cannot be empty.");

        postCount++;
        posts[postCount] = Post({
            postId: postCount,
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0
        });

        emit PostCreated(postCount, msg.sender, _content, block.timestamp);
    }

    function likePost(uint256 _postId) external onlyRegisteredUser {
        require(_postId > 0 && _postId <= postCount, "Post does not exist.");
        require(!postLikes[_postId][msg.sender], "You have already liked this post.");

        posts[_postId].likes++;
        postLikes[_postId][msg.sender] = true;

        emit PostLiked(_postId, msg.sender);
    }

    function getPost(uint256 _postId) external view returns (Post memory) {
        require(_postId > 0 && _postId <= postCount, "Post does not exist.");
        return posts[_postId];
    }

    function getUser(address _userAddress) external view returns (User memory) {
        require(bytes(users[_userAddress].username).length > 0, "User does not exist.");
        return users[_userAddress];
    }

    function getUserPosts(address _userAddress) external view returns (Post[] memory) {
        require(bytes(users[_userAddress].username).length > 0, "User does not exist.");
        
        uint256 count = 0;
        for (uint256 i = 1; i <= postCount; i++) {
            if (posts[i].author == _userAddress) {
                count++;
            }
        }

        Post[] memory userPosts = new Post[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= postCount; i++) {
            if (posts[i].author == _userAddress) {
                userPosts[index] = posts[i];
                index++;
            }
        }

        return userPosts;
    }
}
