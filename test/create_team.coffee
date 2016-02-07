Helper = require 'hubot-test-helper'

chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

helper = new Helper('../scripts/hack24api.coffee')

describe 'Create team', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  describe 'hubot creates a team for an existing user and adds the user to the team', ->

    it 'should create the team with this user as the only member, and reply with a welcome message', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      getExecStub = sinon.stub()
      getStub = sinon.stub()
      getStub.returns getExecStub
      
      postExecStub = sinon.stub()
      postStub = sinon.stub()
      headerStub = sinon.stub().returns { post: postStub, get: getStub }
      postStub.returns postExecStub
      
      http = @room.robot.http = sinon.stub()
      http.returns { header: headerStub }
      
      userResponse = JSON.stringify
        id: 'bob'
      
      getExecStub.callsArgWith(0, null, { statusCode: 200 }, userResponse)
      postExecStub.callsArgWith(0, null, { statusCode: 201 }, null)
      
      @room.user.say('bob', '@hubot create team Pineapple Express').then =>
        expect(http).to.have.been.calledWith("#{apiUrl}/users/bob")
        expect(headerStub).to.have.been.calledWith('Accept', 'application/json')
        
        expect(http).to.have.been.calledWith("#{apiUrl}/teams")
        expect(headerStub).to.have.been.calledWith('Content-Type', 'application/json')
        
        expect(postStub).to.have.been.calledWith('{"name":"Pineapple Express","members":["bob"]}')
        
        expect(@room.messages).to.eql [
          ['bob', '@hubot create team Pineapple Express'],
          ['hubot', "@bob Welcome to team Pineapple Express!"]
        ]

  describe 'hubot tries to create a team for a user already in a team', ->

    it 'should respond to the user that they cannot be in more than one team', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      getExecStub = sinon.stub()
      getStub = sinon.stub()
      getStub.returns getExecStub
      
      headerStub = sinon.stub().returns { get: getStub }
      
      http = @room.robot.http = sinon.stub()
      http.returns { header: headerStub }
      
      userResponse = JSON.stringify
        id: 'barry'
        team: 'Pineapple Express'
      
      getExecStub.callsArgWith(0, null, { statusCode: 200 }, userResponse)
      
      @room.user.say('barry', '@hubot create team Bobby Dazzlers').then =>
        expect(http).to.have.been.calledWith("#{apiUrl}/users/barry")
        expect(headerStub).to.have.been.calledWith('Accept', 'application/json')
        
        expect(@room.messages).to.eql [
          ['barry', '@hubot create team Bobby Dazzlers'],
          ['hubot', "@barry You're already a member of Pineapple Express!"]
        ]

  describe 'hubot tries to create a team which already exists', ->

    it 'should reject the action and tell the user that the team already exists', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      getExecStub = sinon.stub()
      getStub = sinon.stub()
      getStub.returns getExecStub
      
      postExecStub = sinon.stub()
      postStub = sinon.stub()
      headerStub = sinon.stub().returns { post: postStub, get: getStub }
      postStub.returns postExecStub
      
      http = @room.robot.http = sinon.stub()
      http.returns { header: headerStub }
      
      userResponse = JSON.stringify
        id: 'jerry'
      
      getExecStub.callsArgWith(0, null, { statusCode: 200 }, userResponse)
      postExecStub.callsArgWith(0, null, { statusCode: 409 }, null)
      
      @room.user.say('jerry', '@hubot create team Top Bants').then =>
        expect(@room.messages).to.eql [
          ['jerry', '@hubot create team Top Bants'],
            ['hubot', "@jerry Sorry, but that team already exists!"]
        ]

  describe 'hubot creates the user, creates a team, and adds the user to the team', ->

    it 'should create the user, create the team with this user as the only member, and reply with a welcome message', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      usersGetExecStub = sinon.stub()
      usersGetStub = sinon.stub()
      usersGetStub.returns usersGetExecStub
      
      usersPostExecStub = sinon.stub()
      usersPostStub = sinon.stub()
      usersPostStub.returns usersPostExecStub
      
      teamsPostExecStub = sinon.stub()
      teamsPostStub = sinon.stub()
      teamsPostStub.returns teamsPostExecStub
      
      usersGetHeadersStub = sinon.stub().returns { get: usersGetStub }
      usersPostHeadersStub = sinon.stub().returns { post: usersPostStub }
      teamsHeadersStub = sinon.stub().returns { post: teamsPostStub }
      
      http = @room.robot.http = sinon.stub()
      http.withArgs("#{apiUrl}/users/sarah").returns { header: usersGetHeadersStub }
      http.withArgs("#{apiUrl}/users").returns { header: usersPostHeadersStub }
      http.withArgs("#{apiUrl}/teams").returns { header: teamsHeadersStub }
      
      usersGetExecStub.callsArgWith(0, null, { statusCode: 404 }, null)
      usersPostExecStub.callsArgWith(0, null, { statusCode: 201 }, null)
      
      teamsPostExecStub.callsArgWith(0, null, { statusCode: 201 }, null)
      
      @room.user.say('sarah', '@hubot create team Pineapple Express').then =>
        expect(usersGetHeadersStub).to.have.been.calledWith('Accept', 'application/json')
        expect(usersPostHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
        
        expect(teamsHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
        
        expect(usersPostStub).to.have.been.calledWith('{"userid":"sarah","name":"sarah"}')
        expect(teamsPostStub).to.have.been.calledWith('{"name":"Pineapple Express","members":["sarah"]}')
        
        expect(@room.messages).to.eql [
          ['sarah', '@hubot create team Pineapple Express'],
          ['hubot', "@sarah Welcome to team Pineapple Express!"]
        ]

  describe 'hubot can\'t create user when trying to create team', ->

    it 'should respond with a failure message', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      usersGetExecStub = sinon.stub()
      usersGetStub = sinon.stub()
      usersGetStub.returns usersGetExecStub
      
      usersPostExecStub = sinon.stub()
      usersPostStub = sinon.stub()
      usersPostStub.returns usersPostExecStub
      
      usersGetHeadersStub = sinon.stub().returns { get: usersGetStub }
      usersPostHeadersStub = sinon.stub().returns { post: usersPostStub }
      
      http = @room.robot.http = sinon.stub()
      http.withArgs("#{apiUrl}/users/sarah").returns { header: usersGetHeadersStub }
      http.withArgs("#{apiUrl}/users").returns { header: usersPostHeadersStub }
      
      usersGetExecStub.callsArgWith(0, null, { statusCode: 404 }, null)
      usersPostExecStub.callsArgWith(0, null, { statusCode: 54 }, null)
      
      @room.user.say('sarah', '@hubot create team :melon:').then =>
        expect(@room.messages).to.eql [
          ['sarah', '@hubot create team :melon:'],
          ['hubot', "@sarah Sorry, I can't create your user account :frowning:"]
        ]

  describe 'hubot creates the user, but cannot create the team, even though it is unique', ->

    it 'should create the user, but respond with a message when create team fails', ->
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      usersGetExecStub = sinon.stub()
      usersGetStub = sinon.stub()
      usersGetStub.returns usersGetExecStub
      
      usersPostExecStub = sinon.stub()
      usersPostStub = sinon.stub()
      usersPostStub.returns usersPostExecStub
      
      teamsPostExecStub = sinon.stub()
      teamsPostStub = sinon.stub()
      teamsPostStub.returns teamsPostExecStub
      
      usersGetHeadersStub = sinon.stub().returns { get: usersGetStub }
      usersPostHeadersStub = sinon.stub().returns { post: usersPostStub }
      teamsHeadersStub = sinon.stub().returns { post: teamsPostStub }
      
      http = @room.robot.http = sinon.stub()
      http.withArgs("#{apiUrl}/users/sarah").returns { header: usersGetHeadersStub }
      http.withArgs("#{apiUrl}/users").returns { header: usersPostHeadersStub }
      http.withArgs("#{apiUrl}/teams").returns { header: teamsHeadersStub }
      
      usersGetExecStub.callsArgWith(0, null, { statusCode: 404 }, null)
      usersPostExecStub.callsArgWith(0, null, { statusCode: 201 }, null)
      
      teamsPostExecStub.callsArgWith(0, null, { statusCode: 404 }, null)
      
      @room.user.say('sarah', '@hubot create team Whizzbang').then =>
        expect(@room.messages).to.eql [
          ['sarah', '@hubot create team Whizzbang'],
          ['hubot', "@sarah Sorry, I can't create your team :frowning:"]
        ]