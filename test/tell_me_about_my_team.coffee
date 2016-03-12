chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot tell me about my team', ->

  describe 'when in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
      @teamName = 'Pointy Wizards'
      @firstTeamMember = 'Jerry'
      @secondTeamMember = 'Bob'
      @thirdTeamMember = 'Perry'
        
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team:
            name: @teamName
            members: [{
              name: @firstTeamMember
            },{
              name: @secondTeamMember
            },{
              name: @thirdTeamMember
            }]
      
      @room.robot.hack24client =
        getUser: @getUserStub
      
      @room.user.say(@userId, "@hubot tell me about my team").then done

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about my team"],
        ['hubot', "@#{@userId} \"#{@teamName}\" has 3 members: #{@firstTeamMember}, #{@secondTeamMember}, #{@thirdTeamMember}"]
      ]
    
    after ->
      @room.destroy()

  describe 'when not in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
        
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team: null
      
      @room.robot.hack24client =
        getUser: @getUserStub
      
      @room.user.say(@userId, "@hubot tell me about my team").then done

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user that they are not in a team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about my team"],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]
    
    after ->
      @room.destroy()

  describe 'when user is unknown', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
        
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @room.robot.hack24client =
        getUser: @getUserStub
      
      @room.user.say(@userId, "@hubot tell me about my team").then done

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user that they are not in a team', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about my team"],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]
    
    after ->
      @room.destroy()

  describe 'when getUser errors', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
      
      @room.robot.hack24client =
        getUser: ->
          Promise.reject new Error('unknown')
      
      @room.user.say(@userId, "@hubot tell me about my team").then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about my team"],
        ['hubot', "@#{@userId} I'm sorry Sir, there appears to be a big problem!"]
      ]
    
    after ->
      @room.destroy()
