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
      
      @getUserStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        user:
          team:
            teamid: 'ocean-mongrels'
      
      teamResponse = 
        name: 'Ocean Mongrels'
        members: [ 'micah', 'U5678' ]
        
      @getTeamStub = sinon.stub().returns Promise.resolve
        statusCode: 200
        team: teamResponse
        
      @updateTeamStub = sinon.stub().returns Promise.resolve
        statusCode: 200
      
      @room.robot.hack24client =
        getUser: @getUserStub
        updateTeam: @updateTeamStub
        getTeam: @getTeamStub
      
      @room.user.say('micah', '@hubot leave my team').then done

    it 'should get the user for the teamId', ->
      expect(@getUserStub).to.have.been.calledWith('micah')

    it 'should get the team by teamId', ->
      expect(@getTeamStub).to.have.been.calledWith('ocean-mongrels')

    it 'should update the team, excluding the current user in the member list', ->
      expect(@updateTeamStub).to.have.been.calledWith('ocean-mongrels', sinon.match({ members: [ 'U5678' ] }))

    it 'should tell the user that they have left the team', ->
      expect(@room.messages).to.eql [
        ['micah', '@hubot leave my team'],
        ['hubot', '@micah OK, I\'ve removed you from team "Ocean Mongrels"']
      ]
    
    after ->
      @room.destroy()

  describe 'when not in a team', ->
  
#     before (done) ->
#       @room = helper.createRoom()
#       
#       @getTeamStub = sinon.stub().returns Promise.resolve
#         statusCode: 404
#       
#       @room.robot.hack24client =
#         getTeam: @getTeamStub
#       
#       @room.user.say('sarah', '@hubot tell me about team  :smile:').then done
# 
#     it 'should fetch the team by slug (teamid)', ->
#       expect(@getTeamStub).to.have.been.calledWith('smile')
# 
#     it 'should tell the user the team does not exist', ->
#       expect(@room.messages).to.eql [
#         ['sarah', '@hubot tell me about team  :smile:'],
#         ['hubot', '@sarah Sorry, I can\'t find that team.']
#       ]
#     
#     after ->
#       @room.destroy()