chai   = require 'chai'
helper = require './test-helper'
assert = chai.assert
nock   = require 'nock'

api = nock('https://api.github.com')

describe 'hubot checkpoint', ->
  beforeEach (done) ->
    @robot = helper.robot()
    @user  = helper.testUser @robot
    @robot.adapter.on 'connected', ->
      @robot.loadFile  helper.SCRIPTS_PATH, 'checkpoint.coffee'
      @robot.parseHelp "#{helper.SCRIPTS_PATH}/checkpoint.coffee"
      done()
    @robot.run()

  afterEach ->
    @robot.shutdown()

  it 'should be included in /help', ->
    assert.include @robot.commands[0], 'checkpoint'

  it 'should not do anything if not used with Slack', (done) ->
    helper.converse @robot, @user, '/checkpoint in foo/bar#123', (_, response) ->
      assert.equal response, 'I cannot do anything outside of Slack...'
      done()

  describe 'with adapter = slack', ->
    beforeEach () ->
      # force slack (virtually)
      @robot.adapterName = 'slack'

    it 'should create a new comment with the Slack permalink', (done) ->
      api
        .post(
          '/repos/foo/bar/issues/123/comments',
          { body: [
            'FTR, we have discussed this on Slack:',
            'https://tailordev.slack.com/archives/TestRoom/p0',
          ].join(' ') }
        )
        .reply(201, { number: 123, html_url: 'comment-url' })

      helper.converse @robot, @user, '/checkpoint in foo/bar#123', (_, response) ->
        assert.equal response, 'This conversation :point_up: is now engraved forever! (comment-url)'
        done()

    it 'should use the default organization', (done) ->
      api
        .post(
          '/repos/TailorDev/ba-bar/issues/123/comments',
          { body: [
            'FTR, we have discussed this on Slack:',
            'https://tailordev.slack.com/archives/TestRoom/p0',
          ].join(' ') }
        )
        .reply(201, { number: 123, html_url: 'comment-url' })

      helper.converse @robot, @user, '/checkpoint in ba-bar#123', (_, response) ->
        assert.equal response, 'This conversation :point_up: is now engraved forever! (comment-url)'
        done()

    it 'should deal with errors', (done) ->
      api
        .post(
          '/repos/TailorDev/ba-bar/issues/123/comments',
          { body: [
            'FTR, we have discussed this on Slack:',
            'https://tailordev.slack.com/archives/TestRoom/p0',
          ].join(' ') }
        )
        .reply(404, { message: '404' })

      helper.converse @robot, @user, '/checkpoint ba-bar#123', (_, response) ->
        assert.equal response, 'Looks like something went wrong... :confused:'
        done()
