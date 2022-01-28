enum MessageType {
  // start the game with the current players
  startGame,

  // leave group
  leaveGroup,

  // send info that name changed
  changeName,

  // send the color you tapped
  sendColorTapped,
}

MessageType getMessageTypeFromString(String typeString) {
  if (typeString == "startGame")
    return MessageType.startGame;
  else if (typeString == "leaveGroup")
    return MessageType.leaveGroup;
  else if (typeString == "changeName")
    return MessageType.changeName;
  else if (typeString == "sendColorTapped")
    return MessageType.sendColorTapped;
  else
    return null;
}
