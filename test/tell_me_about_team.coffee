chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot tell me about team X', ->

  describe 'with an existing team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      teamResponse = 
        name: 'My Crazy Team Name'
        members: [ 'U1234', 'U5678' ]
        
      getUserStub = sinon.stub()
      
      getUserStub.withArgs('U1234').returns Promise.resolve
        user: 
          name: 'John'
            
      getUserStub.withArgs('U5678').returns Promise.resolve
        user:
          name: 'Barry'
      
      @room.robot.hack24client =
        getTeamByName: ->
          Promise.resolve
            statusCode: 200
            team: teamResponse
        getUser: getUserStub
      
      @room.user.say('sarah', '@hubot tell me about team my crazy team name').then done

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team my crazy team name'],
        ['hubot', '@sarah "My Crazy Team Name" has 2 members: John, Barry']
      ]
    
    after ->
      @room.destroy()