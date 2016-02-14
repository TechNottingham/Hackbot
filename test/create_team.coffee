chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot create team X', ->

  describe 'with an existing user', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        user: {}
      
      @createTeamStub = sinon.stub().returns Promise.resolve 201
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createTeam: @createTeamStub
      
      @room.user.say('bob', '@hubot create team Pineapple Express').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('bob')

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith('Pineapple Express', 'bob')

    it 'should welcome the user to the team', ->
      expect(@room.messages).to.eql [
        ['bob', '@hubot create team Pineapple Express'],
        ['hubot', "@bob Welcome to team Pineapple Express!"]
      ]

  describe 'when the user is already in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        user:
          team: 'Pineapple Express'
      
      @room.robot.hack24client =
        getUser: @getUserStub
      
      @room.user.say('barry', '@hubot create team Bobby Dazzlers').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('barry')

    it 'should tell the user that they cannot be in more than one team', ->
      expect(@room.messages).to.eql [
        ['barry', '@hubot create team Bobby Dazzlers'],
        ['hubot', "@barry You're already a member of Pineapple Express!"]
      ]

  describe 'when user and team already exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        user: {}
      
      @createTeamStub = sinon.stub().returns Promise.resolve 409
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createTeam: @createTeamStub
      
      @room.user.say('jerry', '@hubot create team Top Bants').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('jerry')

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith('Top Bants', 'jerry')

    it 'should tell the user that the team already exists', ->
      expect(@room.messages).to.eql [
        ['jerry', '@hubot create team Top Bants'],
        ['hubot', "@jerry Sorry, but that team already exists!"]
      ]

  describe 'when user and team do not already exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve 201
      
      @createTeamStub = sinon.stub().returns Promise.resolve 201
      
      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
        createTeam: @createTeamStub
      
      @room.user.say('sarah', '@hubot create team Pineapple Express').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('sarah')

    it 'should create the user', ->
      expect(@createUserStub).to.have.been.calledWith('sarah', 'sarah')

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith('Pineapple Express', 'sarah')

    it 'should welcome the new user to the new team', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot create team Pineapple Express'],
        ['hubot', "@sarah Welcome to team Pineapple Express!"]
      ]

  describe 'when creating user returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve 54

      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
      
      @room.user.say('hannah', '@hubot create team :melon:').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('hannah')

    it 'should create the user', ->
      expect(@createUserStub).to.have.been.calledWith('hannah', 'hannah')

    it 'should tell the user that their user account could not be created', ->
      expect(@room.messages).to.eql [
        ['hannah', '@hubot create team :melon:'],
        ['hubot', "@hannah Sorry, I can't create your user account :frowning:"]
      ]

  describe 'when creating the user succeeds and creating the team returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 404
      
      @createUserStub = sinon.stub().returns Promise.resolve 201
      
      @createTeamStub = sinon.stub().returns Promise.resolve 503

      @room.robot.hack24client =
        getUser: @getUserStub
        createUser: @createUserStub
        createTeam: @createTeamStub

      @room.user.say('sarah', '@hubot create team Whizzbang').then done

    after ->
      @room.destroy()

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith('sarah')

    it 'should create the user', ->
      expect(@createUserStub).to.have.been.calledWith('sarah', 'sarah')

    it 'should create the team', ->
      expect(@createTeamStub).to.have.been.calledWith('Whizzbang', 'sarah')

    it 'should tell the user that the team could not be created', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot create team Whizzbang'],
        ['hubot', "@sarah Sorry, I can't create your team :frowning:"]
      ]

  describe 'when user already exists and creating the team returns an unexpected code', ->
  
    before (done) ->
      @room = helper.createRoom()

      @room.robot.hack24client =
        getUser: ->
          Promise.resolve({ statusCode: 200, user: { } })
        createTeam: ->
          Promise.resolve(503)

      @room.user.say('sarah', '@hubot create team Whizzbang').then done

    after ->
      @room.destroy()

    it 'should tell the user that the team could not be created', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot create team Whizzbang'],
        ['hubot', "@sarah Sorry, I can't create your team :frowning:"]
      ]