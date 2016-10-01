# Description:
#   A hubot script to manage the ModernScienceWeekly newsletter.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#
# Commands:
#   hubot msw add <link> as <issue title> - Create a new issue in the MSW repo.
#
# Author:
#   William Durand

githubot = require 'githubot'

module.exports = (robot) ->
  gh = githubot(robot)
  gh.handleErrors (response) ->
    console.log response

  slackLink = (channel, timestamp) ->
    ts = timestamp.replace('.', '')
    return "https://tailordev.slack.com/archives/#{channel}/p#{ts}"

  createIssue = (payload, res) ->
    url = "/repos/TailorDev/ModernScienceWeekly/issues"

    gh.post url, payload, (issue) ->
      res.reply "I've opened the issue ##{issue.number} (#{issue.html_url})"

  ###
  Listeners
  ###

  robot.respond /msw add (https?:\/\/[^\s]+)(\sas\s(.+))?/i, (msg) ->
    link = msg.match[1]
    title = msg.match[3] || 'New link from Slack'

    permalink = 'none'
    if robot.adapterName is "slack"
      # cf. https://github.com/slackhq/hubot-slack/issues/328
      channel = msg.message.user.room
      if /^C.+/.test channel
        room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById room
        channel = room.name

      permalink = slackLink channel, msg.message.id

    payload =
      title: title
      body: "#{link}\n\n---\nSlack URL: #{permalink}"

    createIssue payload, msg
