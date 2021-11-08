enum MessageType {
  // send invite to a peer
  sendInvite,

  // accept the invite
  acceptInvite,

  // send a message with the new list of players
  updatePlayers,

  // leave group
  leaveGroup,
}
