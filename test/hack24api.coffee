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
      
      res = { statusCode: 200 }
      
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