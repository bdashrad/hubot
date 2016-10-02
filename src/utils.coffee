exports.getRoomName = (robot, message) ->
  name = message.user.room
  if robot.adapterName is "slack"
    # if it is a channel, not a DM
    if name[0] is 'C'
      # cf. https://github.com/slackhq/hubot-slack/issues/328
      room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById name
      name = room.name
  return name
