chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot tell me about team X', ->

  describe 'when team exists with members', ->

    before (done) ->
      @room = helper.createRoom()

      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          id: 'my-crazy-team-name'
          name: 'My Crazy Team Name'
          members: [{
            id: 'user1'
            name: 'John'
          },{
            id: 'user2'
            name: 'Barry'
          }]

      @room.robot.hack24client =
        getTeam: @getTeamStub

      @room.user.say('sarah', '@hubot tell me about team     My Crazy team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     My Crazy team name         '],
        ['hubot', '@sarah "My Crazy Team Name" has 2 members: John, Barry']
      ]

    after ->
      @room.destroy()
