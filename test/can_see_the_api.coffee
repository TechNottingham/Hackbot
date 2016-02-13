Helper = require 'hubot-test-helper'

chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

helper = new Helper('../scripts/hack24api.coffee')

describe 'Can see the API', ->
    
  describe 'hubot can see the API', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @apiUrl = process.env.HACK24API_URL = 'some API url'
      
      getExec = sinon.stub()
      get = sinon.stub().returns(getExec)
      getExec.callsArgWith(0, null, { statusCode: 200 }, null)
      
      @http = @room.robot.http = sinon.stub()
      @http.returns { get: get }
      
      @room.user.say('bob', '@hubot can you see the api?').then done

    after ->
      @room.destroy()

    it 'should check the API is available', ->
        expect(@http).to.have.been.calledWith("#{@apiUrl}/api")

    it 'should reply to the user that the API is available', ->
        expect(@room.messages).to.eql [
          ['bob', '@hubot can you see the api?'],
          ['hubot', "@bob I'll have a quick look for you Sir..."],
          ['hubot', '@bob I see her!']
        ]

  describe 'hubot is unable to see the API', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      apiUrl = process.env.HACK24API_URL = 'any url to he API'
      
      getExec = sinon.stub()
      get = sinon.stub().returns(getExec)
      getExec.callsArgWith(0, null, { statusCode: 99 }, '')
      
      http = @room.robot.http = sinon.stub()
      http.returns { get: get }
      
      @room.user.say('bob', '@hubot can you see the api?').then done

    after ->
      @room.destroy()
      
    it 'should reply to the user that he cannot see the API', ->
        expect(@room.messages).to.eql [
          ['bob', '@hubot can you see the api?'],
          ['hubot', "@bob I'll have a quick look for you Sir..."],
          ['hubot', '@bob I\'m sorry Sir, there appears to be a problem; something about "99"']
        ]

  describe 'hubot is unable to see the API because of a http error', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      apiUrl = process.env.HACK24API_URL = 'any url to he API'
      
      getExec = sinon.stub()
      get = sinon.stub().returns(getExec)
      getExec.callsArgWith(0, 'massive problem')
      
      http = @room.robot.http = sinon.stub()
      http.returns { get: get }
      
      @room.user.say('bob', '@hubot can you see the api?').then done

    after ->
      @room.destroy()

    it 'should reply to the user that he cannot see the API because of a big problem', ->
      expect(@room.messages).to.eql [
        ['bob', '@hubot can you see the api?'],
        ['hubot', "@bob I'll have a quick look for you Sir..."],
        ['hubot', '@bob I\'m sorry Sir, there appears to be a big problem!']
      ]