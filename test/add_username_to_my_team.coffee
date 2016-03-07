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
      
      @getUserStub = sinon.stub()
      @getUserStub.withArgs(@userId).returns Promise.resolve
        ok: true
        user:
          team:
            id: @existingTeamId
            name: @existingTeamName
            
      @getUserStub.withArgs(@otherUserId).returns Promise.resolve
        ok: true
        statusCode: 200
      
      @addUserToTeamStub = sinon.stub().returns Promise.resolve
        ok: true

      @room.robot.hack24client =
        getUser: @getUserStub
        addUserToTeam: @addUserToTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      @room.robot.brain.data.users[@otherUserId] =
        id: @otherUserId
        name: @otherUserUsername
      
      @room.user.say(@userId, "@hubot add @#{@otherUserUsername} to my team").then done

    it 'should get the current user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)
      
    it 'should get the other user', ->
      expect(@getUserStub).to.have.been.calledWith(@otherUserId)

    it 'should add the other user to the team', ->
      expect(@addUserToTeamStub).to.have.been.calledWith(@existingTeamId, @otherUserId, @userEmail)

    it 'should tell the user that the command has completed', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot add @#{@otherUserUsername} to my team"],
        ['hubot', "@#{@userId} Done!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when not an attendee', ->
  
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
        ok: false
        statusCode: 403

      @room.robot.hack24client =
        getUser: @getUserStub
        addUserToTeam: @addUserToTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      @room.robot.brain.data.users[@otherUserId] =
        name: @otherUserUsername
      
      @room.user.say(@userId, "@hubot add @#{@otherUserUsername} to my team").then done

    it 'should tell the user that they do not have permission', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot add @#{@otherUserUsername} to my team"],
        ['hubot', "@#{@userId} Sorry, you don't have permission to add people to your team."]
      ]
    
    after ->
      @room.destroy()

  describe 'when not in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'micah'
      @userEmail = 'micah.micah~micah'
      @otherUserUsername = 'pollygrafanaasa'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team: null
      
      @room.robot.hack24client =
        getUser: @getUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot add @#{@otherUserUsername} to my team").then done

    it 'shouldtell the user that they are not in a team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot add @#{@otherUserUsername} to my team"],
        ['hubot', "@#{@userId} I would, but you're not in a team..."]
      ]
    
    after ->
      @room.destroy()

  describe 'when user is not already a member', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'micah'
      @userEmail = 'micah.micah~micah'
      @otherUserId = 'polly'
      @otherUserUsername = 'pollygrafanaasa'
      @existingTeamId = 'ocean-mongrels'
      @existingTeamName = 'Ocean Mongrels'
      
      @getUserStub = sinon.stub()
      @getUserStub.withArgs(@userId).returns Promise.resolve
        ok: true
        user:
          team:
            id: @existingTeamId
            name: @existingTeamName
            
      @getUserStub.withArgs(@otherUserId).returns Promise.resolve
        ok: false
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve
        ok: true
      
      @addUserToTeamStub = sinon.stub().returns Promise.resolve
        ok: true

      @room.robot.hack24client =
        getUser: @getUserStub
        addUserToTeam: @addUserToTeamStub
        createUser: @createUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      @room.robot.brain.data.users[@otherUserId] =
        id: @otherUserId
        name: @otherUserUsername
      
      @room.user.say(@userId, "@hubot add @#{@otherUserUsername} to my team").then done

    it 'should get the current user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)
      
    it 'should get the other user', ->
      expect(@getUserStub).to.have.been.calledWith(@otherUserId)

    it 'should create the other user', ->
      expect(@createUserStub).to.have.been.calledWith(@otherUserId, @otherUserUsername, @userEmail)

    it 'should add the other user to the team', ->
      expect(@addUserToTeamStub).to.have.been.calledWith(@existingTeamId, @otherUserId, @userEmail)

    it 'should tell the user that the command has completed', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot add @#{@otherUserUsername} to my team"],
        ['hubot', "@#{@userId} Done!"]
      ]
    
    after ->
      @room.destroy()