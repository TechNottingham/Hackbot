chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot tell me about team X', ->

  describe 'when team exists with members and a motto', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'jerry'
      @teamId = 'my-crazy-team-name'
      @teamName = 'My Crazy Team Name'
      @firstTeamMember = 'Jerry'
      @secondTeamMember = 'Bob'
      @motto = 'Pikes and spikes hurt on bikes'
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          id: @teamId
          name: @teamName
          motto: @motto
          members: [{
            name: @firstTeamMember
          },{
            name: @secondTeamMember
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say(@userId, "@hubot tell me about team     #{@teamName}         ").then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith(@teamId)

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about team     #{@teamName}         "],
        ['hubot', "@#{@userId} \"#{@teamName}\" has 2 members: #{@firstTeamMember}, #{@secondTeamMember}\r\nThey say: #{@motto}"]
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with one member and no motto', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'megan'
      @teamName = 'My Crazy Team Name'
      @teamMember = 'John'
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          name: 'My Crazy Team Name'
          motto: null
          members: [{
            name: @teamMember
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say(@userId, "@hubot tell me about team     #{@teamName}         ").then done

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about team     #{@teamName}         "],
        ['hubot', "@#{@userId} \"#{@teamName}\" has 1 member: #{@teamMember}\r\nThey don't yet have a motto!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with the user as the only member and a motto', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'frank'
      @teamName = 'My Crazy Team Name'
      @motto = 'Hipsters, everywhere!'
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          name: @teamName
          motto: @motto
          members: [{
            id: @userId
            name: @userId
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say(@userId, "@hubot tell me about team     #{@teamName}         ").then done

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about team     #{@teamName}         "],
        ['hubot', "@#{@userId} You are the only member of \"#{@teamName}\" and your motto is: #{@motto}"]
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with the user as the only member and no motto', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @userId = 'frank'
      @teamName = 'My Crazy Team Name'
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          name: @teamName
          motto: null
          members: [{
            id: @userId
            name: @userId
          }]
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say(@userId, "@hubot tell me about team     #{@teamName}         ").then done

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot tell me about team     #{@teamName}         "],
        ['hubot', "@#{@userId} You are the only member of \"#{@teamName}\" and you have not yet set your motto!"]
      ]
    
    after ->
      @room.destroy()

  describe 'when team exists with no members', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: true
        team:
          id: 'my-crazy-team-name'
          name: 'My Crazy Team Name'
          members: []
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team     my cRAZY team name         ').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('my-crazy-team-name')

    it 'should tell the user the team information', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my cRAZY team name         '],
        ['hubot', '@sarah "My Crazy Team Name" is an empty team.']
      ]
    
    after ->
      @room.destroy()

  describe 'when team does not exist', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @getTeamStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404
      
      @room.robot.hack24client =
        getTeam: @getTeamStub
      
      @room.user.say('sarah', '@hubot tell me about team  :smile:').then done

    it 'should fetch the team by slug (teamid)', ->
      expect(@getTeamStub).to.have.been.calledWith('smile')

    it 'should tell the user the team does not exist', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team  :smile:'],
        ['hubot', '@sarah Sorry, I can\'t find that team.']
      ]
    
    after ->
      @room.destroy()

  describe 'when get team fails', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @room.robot.hack24client =
        getTeam: ->
          Promise.resolve
            ok: false
      
      @room.user.say('sarah', '@hubot tell me about team     my crazy team name         ').then done

    it 'should tell the user that there is a problem', ->
      expect(@room.messages).to.eql [
        ['sarah', '@hubot tell me about team     my crazy team name         '],
        ['hubot', '@sarah Sorry, there was a problem when I tried to look up that team :frowning:']
      ]
    
    after ->
      @room.destroy()