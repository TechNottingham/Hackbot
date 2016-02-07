Helper = require 'hubot-test-helper'

chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

helper = new Helper('../scripts/hack24api.coffee')

describe 'hack24api script', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()
    
  describe 'hubot can see the API', ->

    it 'should reply to the user that he can see the API', ->
      apiUrl = process.env.HACK24API_URL = 'some API url'
      
      getExec = sinon.stub()
      get = sinon.stub().returns(getExec)
      getExec.callsArgWith(0, null, { statusCode: 200 }, '')
      
      http = @room.robot.http = sinon.stub()
      http.returns { get: get }
      
      @room.user.say('bob', '@hubot can you see the api?').then =>
        expect(http).to.have.been.calledWith("#{apiUrl}/api")
        expect(@room.messages).to.eql [
          ['bob', '@hubot can you see the api?'],
          ['hubot', "@bob I'll have a quick look for you Sir..."],
          ['hubot', '@bob I see her!']
        ]

  describe 'hubot is unable to see the API', ->

    it 'should reply to the user that he cannot see the API', ->
      apiUrl = process.env.HACK24API_URL = 'any url to he API'
      
      res = { statusCode: 99 }
      
      getExec = sinon.stub()
      get = sinon.stub().returns(getExec)
      getExec.callsArgWith(0, null, res, '')
      
      http = @room.robot.http = sinon.stub()
      http.returns { get: get }
      
      @room.user.say('bob', '@hubot can you see the api?').then =>
        expect(http).to.have.been.calledWith("#{apiUrl}/api")
        expect(@room.messages).to.eql [
          ['bob', '@hubot can you see the api?'],
          ['hubot', "@bob I'll have a quick look for you Sir..."],
          ['hubot', '@bob I\'m sorry Sir, there appears to be a problem; something about "99"']
        ]

  describe 'hubot cites his prime directives', ->

    it 'should reply to the user the prime directives', ->
      @room.user.say('bob', '@hubot what are your prime directives?').then =>
        expect(@room.messages).to.eql [
          ['bob', '@hubot what are your prime directives?'],
          ['hubot', "@bob 1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"]
        ]

  describe 'hubot tells the user their id', ->

    it 'should reply to the user with their identifier', ->
      @room.user.say('bob', '@hubot my id').then =>
        expect(@room.messages).to.eql [
          ['bob', '@hubot my id'],
          ['hubot', "@bob Your id is bob"]
        ]

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
      usersPostExecStub.callsArgWith(0, null, { statusCode: 200 }, null)
      
      teamsPostExecStub.callsArgWith(0, null, { statusCode: 200 }, null)
      
      @room.user.say('sarah', '@hubot create team Pineapple Express').then =>
        expect(usersGetHeadersStub).to.have.been.calledWith('Accept', 'application/json')
        expect(usersPostHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
        
        expect(teamsHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
        
        expect(usersPostStub).to.have.been.calledWith('{"id":"sarah","name":"sarah"}')
        expect(teamsPostStub).to.have.been.calledWith('{"name":"Pineapple Express","members":["sarah"]}')
        
        expect(@room.messages).to.eql [
          ['sarah', '@hubot create team Pineapple Express'],
          ['hubot', "@sarah Welcome to team Pineapple Express!"]
        ]