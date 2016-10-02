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
#   hubot msw list <category> - List the last MSW issues (limit = 10).
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
  endpoint = "/repos/#{repository}/issues"

  ###
  Create a new issue given a link and a title (optionally)
  ###
  createIssue = (title, content, cb) ->
    payload =
      title: title
      body: content

    # error handler
    gh.handleErrors (response) ->
      cb response

    gh.post endpoint, payload, (issue) ->
      cb issue

  ###
  ###
  getIssues = (category, limit, cb) ->
    # error handler
    gh.handleErrors (response) ->
      cb response

    url = "#{endpoint}?per_page=#{limit}"
    if category
      url = "#{url}&labels=#{category}"

    gh.get url, (issues) ->
      cb issues

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
        reply = "I've opened the issue <#{response.html_url}|##{response.number}>."

      msg.reply reply

  robot.respond /msw list(\s(.+))?/i, (msg) ->
    category = msg.match[2] || ''
    category = switch category.toLowerCase()
      when 'open' then 'Open Science %26 Data'
      when 'open science' then 'Open Science %26 Data'
      when 'open data' then 'Open Science & Data'
      when 'cutting' then 'Cutting-edge Science'
      when 'cutting edge' then 'Cutting-edge Science'
      when 'cutting-edge' then 'Cutting-edge Science'
      when 'cutting-edge science' then 'Cutting-edge Science'
      when 'tools' then 'Tools for Scientists'
      when 'tools for scientists' then 'Tools for Scientists'
      when 'beyond' then 'Beyond Academia'
      when 'beyond academia' then 'Beyond Academia'
      else ''

    formatTitle = (title) ->
      if title.length > 30
        title = "#{title.substr 0, 27}..."
      return title

    formatLabels = (labels) ->
      s = []
      labels.map (l) ->
        s.push l.name
      if s.length > 0
        return "[#{s.join ', '}]"
      return ''

    getIssues category, 10, (response) ->
      if response.error
        reply = 'Looks like something went wrong... :confused:'
      else
        issues = response
        count = issues.length
        if count is 0
          reply = "There is no issue mate."
        else
          if count is 1
            reply = ["Here is the only issue I've found:", ""]
          else
            reply = ["Here are the last #{count} issues I've found:", ""]

          issues.map (i) ->
            reply.push "#{formatTitle i.title} - #{i.html_url} #{formatLabels i.labels}"
          reply = reply.join "\n"

      msg.reply reply
