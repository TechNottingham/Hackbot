Helper = require 'hubot-test-helper'

chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

helper = new Helper('../scripts/hack24api.coffee')

describe 'Tell me about team', ->

  describe.only 'hubot fetches team information from the API then responds to the user', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      apiUrl = process.env.HACK24API_URL = 'any url to the API'
      
      teamsGetExecStub = sinon.stub()
      teamsGetStub = sinon.stub()
      teamsGetStub.returns teamsGetExecStub
      
      firstUserGetExecStub = sinon.stub()
      firstUserGetStub = sinon.stub()
      firstUserGetStub.returns firstUserGetExecStub
      
      secondUserGetExecStub = sinon.stub()
      secondUserGetStub = sinon.stub()
      secondUserGetStub.returns secondUserGetExecStub
      
      @teamsGetHeadersStub = sinon.stub().returns { get: teamsGetStub }
      @firstUserGetHeadersStub = sinon.stub().returns { get: firstUserGetStub }
      @secondUserGetHeadersStub = sinon.stub().returns { get: secondUserGetStub }
      
      
      http = @room.robot.http = sinon.stub()
      http.withArgs("#{apiUrl}/teams/my crazy team name").returns { header: @teamsGetHeadersStub }
      http.withArgs("#{apiUrl}/users/U1234").returns { header: @firstUserGetHeadersStub }
      http.withArgs("#{apiUrl}/users/U5678").returns { header: @secondUserGetHeadersStub }
      
      teamResponse = JSON.stringify
        name: 'My Crazy Team Name'
        members: [
          'U1234',
          'U5678'
        ]
        
      firstUserResponse = JSON.stringify
        name: 'John'
        
      secondUserResponse = JSON.stringify
        name: 'Barry'
      
      teamsGetExecStub.callsArgWith(0, null, { statusCode: 200 }, teamResponse)
      firstUserGetExecStub.callsArgWith(0, null, { statusCode: 200 }, firstUserResponse)
      secondUserGetExecStub.callsArgWith(0, null, { statusCode: 200 }, secondUserResponse)
      
      @room.user.say('sarah', '@hubot tell me about team my crazy team name').then done

    it 'should get the team', ->
      expect(@teamsGetHeadersStub).to.have.been.calledWith('Accept', 'application/json')

    it 'should get each user in the team', ->
      expect(@firstUserGetHeadersStub).to.have.been.calledWith('Accept', 'application/json')
      expect(@secondUserGetHeadersStub).to.have.been.calledWith('Accept', 'application/json')

    it 'should reply with the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team my crazy team name'],
        ['hubot', '@sarah "My Crazy Team Name" has 2 members: John, Barry']
      ]
    
    after ->
      @room.destroy()