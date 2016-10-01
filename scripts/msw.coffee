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
#   hubot msw add <link> - Create a new issue in the MSW repo.
#
# Author:
#   William Durand

githubot = require 'githubot'

module.exports = (robot) ->
  gh = githubot(robot)
  gh.handleErrors (response) ->
    console.log response

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
    permalink = msg.message.permalink || 'none'

    payload  = {
      title: title,
      body: "#{link}\n\nSlack URL: #{permalink}",
    }

    createIssue payload, msg
