enum MessageType {
  adhocDiscovered,
  adhocDiscoveredEnded,
  adhocConnection,
  adhocConnectionEnded,
  firebaseConnection,
  indirectConnection,
  exchangeUUID,
  startGame,
  leaveGroup,
  sendLevelChange,
  sendColorTapped,
}

MessageType getMessageTypeFromString(String typeString) {
  if (typeString == "adhocDiscovered")
    return MessageType.adhocDiscovered;
  else if (typeString == "adhocConnection")
    return MessageType.adhocConnection;
  else if (typeString == "adhocConnectionEnded")
    return MessageType.adhocConnectionEnded;
  else if (typeString == "adhocDiscoveredEnded")
    return MessageType.adhocDiscoveredEnded;
  else if (typeString == "firebaseConnection")
    return MessageType.firebaseConnection;
  else if (typeString == "indirectConnection")
    return MessageType.indirectConnection;
  else if (typeString == "exchangeUUID")
    return MessageType.exchangeUUID;
  else if (typeString == "startGame")
    return MessageType.startGame;
  else if (typeString == "leaveGroup")
    return MessageType.leaveGroup;
  else if (typeString == "sendLevelChange")
    return MessageType.sendLevelChange;
  else if (typeString == "sendColorTapped")
    return MessageType.sendColorTapped;
  else
    return null;
}
