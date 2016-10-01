chai   = require 'chai'
helper = require './test-helper'
assert = chai.assert
nock   = require 'nock'

api = nock('https://api.github.com')

describe 'hubot msw', ->
  beforeEach (done) ->
    @robot = helper.robot()
    @user  = helper.testUser @robot
    @robot.adapter.on 'connected', ->
      @robot.loadFile  helper.SCRIPTS_PATH, 'msw.coffee'
      @robot.parseHelp "#{helper.SCRIPTS_PATH}/msw.coffee"
      done()
    @robot.run()

  afterEach ->
    @robot.shutdown()

  it 'should be included in /help', ->
    assert.include @robot.commands[0], 'msw'

  it 'should create a new issue with a defaut title', (done) ->
    api
      .post(
        '/repos/TailorDev/ModernScienceWeekly/issues',
        {
          title: 'New link from Slack',
          body: 'http://example.org\n\n---\nSlack URL: none',
        }
      )
      .reply(201, { number: 123, html_url: 'issue-url' })

    helper.converse @robot, @user, '/msw add http://example.org', (_, response) ->
      assert.equal response, "I've opened the issue #123 (issue-url)"
      done()

  it 'should create a new issue with a custom title', (done) ->
    api
      .post(
        '/repos/TailorDev/ModernScienceWeekly/issues',
        {
          title: 'Example.org website',
          body: 'http://example.org\n\n---\nSlack URL: none',
        }
      )
      .reply(201, { number: 123, html_url: 'issue-url' })

    helper.converse @robot, @user, '/msw add http://example.org as Example.org website', (_, response) ->
      assert.equal response, "I've opened the issue #123 (issue-url)"
      done()

  it 'should deal with errors', (done) ->
    api
      .post(
        '/repos/TailorDev/ModernScienceWeekly/issues',
        {
          title: 'Example.org website',
          body: 'http://example.org\n\n---\nSlack URL: none',
        }
      )
      .reply(404, { message: '404' })

    helper.converse @robot, @user, '/msw add http://example.org as Example.org website', (_, response) ->
      assert.equal response, 'Looks like something went wrong... :confused:'
      done()
