enum MessageType {
  // start the game with the current players
  startGame,

  // leave group
  leaveGroup,

  // send info that name changed
  changeName,
}

MessageType getMessageTypeFromString(String typeString) {
  for (MessageType type in MessageType.values) {
    if (type.toString() == typeString)
      return type;
  }
  return null;
}
