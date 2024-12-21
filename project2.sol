// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsForProjects {
    address public owner;
    uint256 public rewardAmount; // The amount of reward for each approved project
    uint256 public totalProjects; // Total number of projects submitted
    mapping(address => uint256[]) public userProjects; // Store user projects by address
    mapping(uint256 => bool) public projectApproved; // Track approval of each project (by ID)
    mapping(uint256 => bool) public rewardClaimed; // Track reward claiming per project
    mapping(uint256 => string) public projectDescriptions; // Store project descriptions by project ID

    event ProjectSubmitted(address indexed user, uint256 indexed projectId, string projectDescription, uint256 timestamp);
    event ProjectApproved(uint256 indexed projectId, uint256 timestamp);
    event RewardClaimed(address indexed user, uint256 indexed projectId, uint256 rewardAmount, uint256 timestamp);
    event ProjectRejected(uint256 indexed projectId, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    modifier projectNotApproved(uint256 projectId) {
        require(!projectApproved[projectId], "Project already approved.");
        _;
    }

    modifier rewardNotClaimed(uint256 projectId) {
        require(!rewardClaimed[projectId], "Reward already claimed.");
        _;
    }

    constructor(uint256 _rewardAmount) {
        owner = msg.sender;
        rewardAmount = _rewardAmount;
        totalProjects = 0;
    }

    // Submit a project with a description
    function submitProject(string memory _projectDescription) external projectNotApproved(totalProjects) {
        uint256 projectId = totalProjects;
        userProjects[msg.sender].push(projectId); // Link user to their projects
        projectDescriptions[projectId] = _projectDescription;
        totalProjects += 1;

        emit ProjectSubmitted(msg.sender, projectId, _projectDescription, block.timestamp);
    }

    // Approve a project (Only the owner can approve)
    function approveProject(uint256 projectId) external onlyOwner projectNotApproved(projectId) {
        require(projectId < totalProjects, "Invalid project ID");
        projectApproved[projectId] = true;

        emit ProjectApproved(projectId, block.timestamp);
    }

    // Reject a project (Only the owner can reject)
    function rejectProject(uint256 projectId) external onlyOwner {
        require(projectId < totalProjects, "Invalid project ID");
        delete projectDescriptions[projectId]; // Clear project details
        delete projectApproved[projectId]; // Mark project as not approved

        emit ProjectRejected(projectId, block.timestamp);
    }

    // Claim reward for an approved project
    function claimReward(uint256 projectId) external rewardNotClaimed(projectId) {
        require(projectApproved[projectId], "Project not approved yet.");
        
        // Transfer the reward to the user
        rewardClaimed[projectId] = true;
        payable(msg.sender).transfer(rewardAmount);

        emit RewardClaimed(msg.sender, projectId, rewardAmount, block.timestamp);
    }

    // Fallback function to accept Ether deposits
    receive() external payable {}

    // Function to withdraw contract's balance (only by owner)
    function withdraw(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance.");
        payable(owner).transfer(_amount);
    }

    // View function to see the balance of the contract
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // View function to see if a project is approved
    function isProjectApproved(uint256 projectId) external view returns (bool) {
        return projectApproved[projectId];
    }

    // View function to see if a reward has been claimed for a project
    function isRewardClaimed(uint256 projectId) external view returns (bool) {
        return rewardClaimed[projectId];
    }
}
