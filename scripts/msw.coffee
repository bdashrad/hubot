# Description:
#   A hubot script to manage the ModernScienceWeekly newsletter.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_SLACK_TEAM
#
# Commands:
#   hubot msw add <link> as <issue title> - Create a new issue in the MSW repo.
#
# Author:
#   William Durand

githubot = require 'githubot'
utils = require '../src/utils'
slack = require '../src/slack'

slackTeam  = process.env.HUBOT_SLACK_TEAM ? 'tailordev'
repository = 'TailorDev/ModernScienceWeekly'

module.exports = (robot) ->
  gh = githubot(robot)

  ###
  Create a new issue given a link and a title (optionally)
  ###
  createIssue = (title, content, cb) ->
    url = "/repos/#{repository}/issues"
    payload =
      title: title
      body: content

    # error handler
    gh.handleErrors (response) ->
      cb response

    gh.post url, payload, (issue) ->
      cb issue

  ###
  Listeners
  ###

  robot.respond /msw add (https?:\/\/[^\s]+)(\sas\s(.+))?/i, (msg) ->
    link = msg.match[1]
    title = msg.match[3] || 'New link from Slack'

    permalink = 'none'
    if robot.adapterName is "slack"
      channel = utils.getRoomName robot, msg.message
      permalink = slack.getPermalink slackTeam, channel, msg.message.id

    content = "#{link}\n\n---\nSlack URL: #{permalink}"

    createIssue title, content, (response) ->
      if response.error
        reply = 'Looks like something went wrong... :confused:'
      else
        reply = "I've opened the issue ##{response.number} (#{response.html_url})"

      msg.reply reply
