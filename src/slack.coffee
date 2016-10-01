exports.getPermalink = (team, channel, timestamp) ->
  ts = timestamp.replace('.', '')
  "https://#{team}.slack.com/archives/#{channel}/p#{ts}"
