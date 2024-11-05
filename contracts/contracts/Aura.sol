// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Aura
 * @dev A social reputation system for managing communities (Reefs)
 */
contract Aura is Ownable {
    struct Member {
        address wallet;
        uint256 auraPoints;
        uint256 currentHalo;
        uint256 lastHaloReset;
        address invitedBy;
        bool isSeedMember;
        bool exists;
    }

    struct Reef {
        string name;
        uint256 baseHaloValue;
        uint256 memberCount;
        bool active;
    }

    // Reef ID => Reef
    mapping(uint256 => Reef) public reefs;
    // Reef ID => Member address => Member details
    mapping(uint256 => mapping(address => Member)) public reefMembers;
    // Reef ID => List of member addresses
    mapping(uint256 => address[]) public reefMemberList;

    uint256 public nextReefId;

    event ReefCreated(
        uint256 indexed reefId,
        string name,
        uint256 baseHaloValue
    );
    event MemberAdded(
        uint256 indexed reefId,
        address indexed member,
        bool isSeedMember
    );
    event HaloTransferred(
        uint256 indexed reefId,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event AuraUpdated(
        uint256 indexed reefId,
        address indexed member,
        uint256 newAura
    );
    event HaloReset(
        uint256 indexed reefId,
        address indexed member,
        uint256 amount
    );

    constructor() Ownable(msg.sender) {}

    function createReef(
        string memory _name,
        uint256 _baseHaloValue
    ) external onlyOwner {
        uint256 reefId = nextReefId++;
        reefs[reefId] = Reef({
            name: _name,
            baseHaloValue: _baseHaloValue,
            memberCount: 0,
            active: true
        });

        emit ReefCreated(reefId, _name, _baseHaloValue);
    }

    function addSeedMembers(
        uint256 _reefId,
        address[] calldata _members
    ) external onlyOwner {
        require(reefs[_reefId].active, "Reef does not exist");

        for (uint i = 0; i < _members.length; i++) {
            address member = _members[i];
            require(
                !reefMembers[_reefId][member].exists,
                "Member already exists"
            );

            reefMembers[_reefId][member] = Member({
                wallet: member,
                auraPoints: 0,
                currentHalo: reefs[_reefId].baseHaloValue,
                lastHaloReset: block.timestamp,
                invitedBy: address(0),
                isSeedMember: true,
                exists: true
            });

            reefMemberList[_reefId].push(member);
            reefs[_reefId].memberCount++;

            emit MemberAdded(_reefId, member, true);
        }
    }

    function inviteMember(uint256 _reefId, address _newMember) external {
        require(reefs[_reefId].active, "Reef does not exist");
        require(reefMembers[_reefId][msg.sender].exists, "Not a reef member");
        require(
            !reefMembers[_reefId][_newMember].exists,
            "Member already exists"
        );

        reefMembers[_reefId][_newMember] = Member({
            wallet: _newMember,
            auraPoints: 0,
            currentHalo: reefs[_reefId].baseHaloValue,
            lastHaloReset: block.timestamp,
            invitedBy: msg.sender,
            isSeedMember: false,
            exists: true
        });

        reefMemberList[_reefId].push(_newMember);
        reefs[_reefId].memberCount++;

        emit MemberAdded(_reefId, _newMember, false);
    }

    function transferHalo(
        uint256 _reefId,
        address _to,
        uint256 _amount
    ) external {
        require(reefs[_reefId].active, "Reef does not exist");
        require(reefMembers[_reefId][msg.sender].exists, "Not a reef member");
        require(
            reefMembers[_reefId][_to].exists,
            "Recipient not a reef member"
        );

        Member storage sender = reefMembers[_reefId][msg.sender];
        Member storage recipient = reefMembers[_reefId][_to];

        _resetHaloIfNeeded(_reefId, msg.sender);
        require(sender.currentHalo >= _amount, "Insufficient Halo");

        sender.currentHalo -= _amount;

        // Update Aura points based on the transfer
        uint256 auraIncrease = calculateAuraIncrease(_amount);
        recipient.auraPoints += auraIncrease;

        // Update Aura for the invitation chain
        address current = recipient.invitedBy;
        uint256 chainMultiplier = 2;

        while (current != address(0) && chainMultiplier > 0) {
            reefMembers[_reefId][current].auraPoints += (auraIncrease /
                chainMultiplier);
            current = reefMembers[_reefId][current].invitedBy;
            chainMultiplier *= 2;
        }

        emit HaloTransferred(_reefId, msg.sender, _to, _amount);
        emit AuraUpdated(_reefId, _to, recipient.auraPoints);
    }

    function _resetHaloIfNeeded(uint256 _reefId, address _member) internal {
        Member storage member = reefMembers[_reefId][msg.sender];

        if (block.timestamp >= member.lastHaloReset + 1 days) {
            member.currentHalo = reefs[_reefId].baseHaloValue;
            member.lastHaloReset = block.timestamp;

            emit HaloReset(_reefId, _member, reefs[_reefId].baseHaloValue);
        }
    }

    function calculateAuraIncrease(
        uint256 _haloAmount
    ) internal pure returns (uint256) {
        // Simple calculation: 1 Halo = 1 Aura point
        // This can be modified to implement more complex formulas
        return _haloAmount;
    }

    // View functions
    function getMemberAura(
        uint256 _reefId,
        address _member
    ) external view returns (uint256) {
        require(reefMembers[_reefId][_member].exists, "Member does not exist");
        return reefMembers[_reefId][_member].auraPoints;
    }

    function getMemberHalo(
        uint256 _reefId,
        address _member
    ) external view returns (uint256) {
        require(reefMembers[_reefId][_member].exists, "Member does not exist");
        return reefMembers[_reefId][_member].currentHalo;
    }

    function getReefMembers(
        uint256 _reefId
    ) external view returns (address[] memory) {
        return reefMemberList[_reefId];
    }
}
