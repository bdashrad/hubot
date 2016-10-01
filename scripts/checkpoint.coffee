# Description:
#   A hubot script to create comments on GitHub issues with links to Slack
#   conversations.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_SLACK_TEAM
#   HUBOT_GITHUB_ORG
#
# Commands:
#   hubot checkpoint <org>/<repo>#<issue> - Comment on a GitHub issue with a link to the current discussion.
#
# Author:
#   William Durand

githubot = require 'githubot'
utils = require '../src/utils'
slack = require '../src/slack'

slackTeam = process.env.HUBOT_SLACK_TEAM ? 'tailordev'
githubOrg = process.env.HUBOT_GITHUB_ORG ? 'TailorDev'

module.exports = (robot) ->
  gh = githubot(robot)

  ###
  Add a new comment on a GitHub issue.
  ###
  createComment = (owner, repo, number, comment, cb) ->
    url = "/repos/#{owner}/#{repo}/issues/#{number}/comments"

    # error handler
    gh.handleErrors (response) ->
      cb response

    gh.post url, { body: comment }, (c) ->
      cb c

  ###
  Listeners
  ###

  robot.respond /checkpoint\s(in\s)?(([-_\.0-9a-z]+)\/)?([-_\.0-9a-z]+)#([0-9]+)/i, (msg) ->
    owner  = msg.match[3] || githubOrg
    repo   = msg.match[4]
    number = msg.match[5]

    if robot.adapterName is "slack"
      channel = utils.getRoomName robot, msg.message
      permalink = slack.getPermalink slackTeam, channel, msg.message.id
      comment = "FTR, we have discussed this on Slack: #{permalink}"

      createComment owner, repo, number, comment, (response) ->
        if response.error
          reply = 'Looks like something went wrong... :confused:'
        else
          reply = [
            'This conversation :point_up: is now engraved forever!',
            "(#{response.html_url})"
          ].join ' '

        msg.reply reply
    else
      msg.reply 'I cannot do anything outside of Slack...'
