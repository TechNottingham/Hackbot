chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot leave my team', ->

  describe 'when in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'micah'
      @userEmail = 'micah.micah~micah'
      @existingTeamId = 'ocean-mongrels'
      @existingTeamName = 'Ocean Mongrels'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: @existingTeamId
            name: @existingTeamName
      
      @removeTeamMemberStub = sinon.stub().returns Promise.resolve
        ok: true
      
      @room.robot.hack24client =
        getUser: @getUserStub
        removeTeamMember: @removeTeamMemberStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: @userEmail
      
      @room.user.say(@userId, '@hubot leave my team').then done

    it 'should get the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should update the team, excluding the current user in the member list', ->
      expect(@removeTeamMemberStub).to.have.been.calledWith(@existingTeamId, @userId, @userEmail)

    it 'should tell the user that they have left the team', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot leave my team'],
        ['hubot', "@#{@userId} OK, you\'ve been removed from team \"#{@existingTeamName}\""]
      ]
    
    after ->
      @room.destroy()

  describe 'when not in a team', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: undefined
      
      @room.robot.hack24client =
        getUser: @getUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'asdlkjalkdsjas'
      
      @room.user.say(@userId, '@hubot leave my team').then done

    it 'should get the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user that they are not in a team', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot leave my team'],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]
    
    after ->
      @room.destroy()

  describe 'when user does not exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'sarah'
      
      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @room.robot.hack24client =
        getUser: @getUserStub
        
      @room.robot.brain.data.users[@userId] =
        email_address: 'sdfsfdsfsdf'
      
      @room.user.say(@userId, '@hubot leave my team').then done

    it 'should get the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should tell the user that they are not in a team', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot leave my team'],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]
    
    after ->
      @room.destroy()

  describe 'when getUser fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @room.robot.hack24client =
        getUser: ->
          Promise.reject new Error('unknown')
      
      @room.user.say('sarah', '@hubot leave my team').then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot leave my team'],
        ['hubot', '@sarah I\'m sorry Sir, there appears to be a big problem!']
      ]
    
    after ->
      @room.destroy()

  describe 'when removeTeamMember fails', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @room.robot.hack24client =
        getUser: ->
          Promise.resolve
            ok: true
            user:
              team:
                id: '234324'
        removeTeamMember: ->
          Promise.reject new Error('when removeTeamMember fails')
      
      @room.user.say('sarah', '@hubot leave my team').then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot leave my team'],
        ['hubot', '@sarah I\'m sorry Sir, there appears to be a big problem!']
      ]
    
    after ->
      @room.destroy()