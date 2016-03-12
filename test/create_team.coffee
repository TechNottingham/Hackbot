chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot create team X', ->

  describe 'when user already exists and not in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'bob'
      @userEmail = 'pinny.espresso@food.co'
      @teamName = 'Pineapple Express'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team: {}
      
      @createTeamStub = sinon.stub().returns Promise.resolve
        ok: true
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createTeam: @createTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith(@teamName, @userId, @userEmail)

    it 'should welcome the user to the team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Welcome to team #{@teamName}!"]
      ]

  describe 'when user already exists and not a registered attendee', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'bob'
      @userEmail = 'pinny.espresso@food.co'
      @teamName = 'Pineapple Express'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team: {}
      
      @createTeamStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 403
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createTeam: @createTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should not welcome the user to the team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Sorry, you don't have permission to create a team."]
      ]

  describe 'when user already exists and is already in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'barry'
      @teamId = 'bodaz'
      @teamName = 'Bobby Dazzlers'
      @existingTeamId = 'pineapple-express'
      @existingTeamName = 'Pineapple Express'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: @existingTeamId
            name: @existingTeamName
      
      @room.robot.hack24client =
        getUser: @getUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'sadadd'
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user that they cannot be in more than one team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} You're already a member of #{@existingTeamName}!"]
      ]

  describe 'when user already exists and team already exists', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
      @userEmail = 'jerry@jerry.jerry'
      @teamName = 'Top Bants'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team: {}
      
      @createTeamStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 409
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createTeam: @createTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should try to create the team', ->
      expect(@createTeamStub).to.have.been.calledWith(@teamName, @userId, @userEmail)

    it 'should tell the user that the team already exists', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot create team Top Bants'],
        ['hubot', "@#{@userId} Sorry, but that team already exists!"]
      ]

  describe 'when user does not already exist and team does not already exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @userEmail = 'sarah@sarah.sarah'
      @teamName = 'Pineapple Express'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve
        ok: true
      
      @createTeamStub = sinon.stub().returns Promise.resolve
        ok: true
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
        createTeam: @createTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should create the user', ->
      expect(@createUserStub).to.have.been.calledWith(@userId, @userId, @userEmail)

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith(@teamName, @userId, @userEmail)

    it 'should welcome the new user to the new team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Welcome to team #{@teamName}!"]
      ]

  describe 'when user does not already exist and not a registered attendee', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @userEmail = 'sarah@sarah.sarah'
      @teamName = 'Pineapple Express'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 403
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
        createTeam: @createTeamStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should welcome the new user to the new team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Sorry, you don\'t have permission to create a team."]
      ]

  describe 'when user does not already exist and create user returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'hannah'
      @userEmail = 'an.email.address'
      @teamName = ':melon:'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 54

      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should create the user', ->
      expect(@createUserStub).to.have.been.calledWith(@userId, @userId)

    it 'should tell the user that their user account could not be created', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Sorry, I can't create your user account :frowning:"]
      ]

  describe 'when user does not already exist and creating the team returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Whizzbang'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: false
            statusCode: 404
        createUser: ->
          Promise.resolve
            ok: true
            statusCode: 201
        createTeam: ->
          Promise.resolve
            ok: false
            statusCode: 503
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'another.email.address'

      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should tell the user that the team could not be created', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Sorry, I can't create your team :frowning:"]
      ]

  describe 'when user already exists and creating the team returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Whizzbang'

      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: true
            user:
              team: {}
        createTeam: ->
          Promise.resolve
            ok: false
            statusCode: 503
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'some.email.address'

      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    after ->
      @room.destroy()

    it 'should tell the user that the team could not be created', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} Sorry, I can't create your team :frowning:"]
      ]

  describe 'when getUser fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Rosie'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.reject new Error('unknown')
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'bark'
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} I'm sorry Sir, there appears to be a big problem!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when user does not exist and createUser fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Rosie'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: false
            statusCode: 404
        createUser: ->
          Promise.reject new Error('unknown')
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'bark'
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} I'm sorry Sir, there appears to be a big problem!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when created user and createTeam fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Rosie'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: true
            user: {}
        createUser: ->
            ok: true
        createTeam: ->
          Promise.reject new Error('unknown')
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'bark'
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} I'm sorry Sir, there appears to be a big problem!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when user already exists and createTeam fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      @teamName = 'Rosie'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: true
            user: {}
        createTeam: ->
          Promise.reject new Error('unknown')
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'bark'
      
      @room.user.say(@userId, "@hubot create team #{@teamName}").then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot create team #{@teamName}"],
        ['hubot', "@#{@userId} I'm sorry Sir, there appears to be a big problem!"]
      ]
    
    after ->
      @room.destroy()