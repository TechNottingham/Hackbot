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

  describe 'when team exists with one member', ->
  
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
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team     my crazy team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my crazy team name         '],
        ['hubot', '@sarah "My Crazy Team Name" has 1 member: John']
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with the user as the only member', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          id: 'my-crazy-team-name'
          name: 'My Crazy Team Name'
          members: [{
            id: 'sarah'
            name: 'Sarah'
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team     my crazy team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my crazy team name         '],
        ['hubot', '@sarah You are the only member of "My Crazy Team Name"']
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with no members', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          id: 'my-crazy-team-name'
          name: 'My Crazy Team Name'
          members: []
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team     my cRAZY team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my cRAZY team name         '],
        ['hubot', '@sarah "My Crazy Team Name" is an empty team.']
      ]
    
    after ->
      @room.destroy()

  describe 'when team does not exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team  :smile:').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('smile')

    it 'should tell the user the team does not exist', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team  :smile:'],
        ['hubot', '@sarah Sorry, I can\'t find that team.']
      ]
    
    after ->
      @room.destroy()

  describe 'when get team fails', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @room.robot.hack24client =
        getTeam: ->
          Promise.resolve
            ok: false
      
      @room.user.say('sarah', '@hubot tell me about team     my crazy team name         ').then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my crazy team name         '],
        ['hubot', '@sarah Sorry, there was a problem when I tried to look up that team :frowning:']
      ]
    
    after ->
      @room.destroy()