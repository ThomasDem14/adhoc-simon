enum MessageType {
  // send invite to a peer
  sendInvite,

  // accept the invite
  acceptInvite,

  // send a message with the new list of players
  updatePlayers,

  // start the game with the current players
  startGame,

  // leave group
  leaveGroup,
}
