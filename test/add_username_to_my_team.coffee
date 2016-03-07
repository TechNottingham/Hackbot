chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot add @username to my team', ->

  describe 'when in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'micah'
      @userEmail = 'micah.micah~micah'
      @otherUserId = 'polly'
      @otherUserUsername = 'pollygrafanaasa'
      @existingTeamId = 'ocean-mongrels'
      @existingTeamName = 'Ocean Mongrels'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: @existingTeamId
            name: @existingTeamName
      
      @addUserToTeamStub = sinon.stub().returns Promise.resolve
        ok: true

      @room.robot.hack24client =
        getUser: @getUserStub
        addUserToTeam: @addUserToTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      @room.robot.brain.data.users[@otherUserId] =
        name: @otherUserUsername
      
      @room.user.say(@userId, "@hubot add @#{@otherUserUsername} to my team").then done

    it 'should get the current user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should add the other user to the team', ->
      expect(@addUserToTeamStub).to.have.been.calledWith(@existingTeamId, @otherUserId, @userEmail)

    it 'should tell the user that the command has completed', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot add @#{@otherUserUsername} to my team"],
        ['hubot', "@#{@userId} Done!"]
      ]
    
    after ->
      @room.destroy()