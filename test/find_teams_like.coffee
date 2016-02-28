chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot find teams like X', ->

  describe 'when matching teams found', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @findTeamsStub = sinon.stub().returns Promise.resolve
        ok: true
        teams: [{
          id: 'hack-hackers-hacking-hacks'
          name: 'Hack Hackers Hacking Hacks'
        },{
          id: 'hackers-hacking-hack-hacks'
          name: 'Hackers Hacking Hack Hacks'
        },{
          id: 'another-team'
          name: 'Another Team'
        },{
          id: 'b'
          name: 'b'
        }]
      
      @room.robot.hack24client =
        findTeams: @findTeamsStub
      
      @room.user.say('paolo', '@hubot find teams like hacking hack').then done

    it 'should find teams matching the search', ->
      expect(@findTeamsStub).to.have.been.calledWith('hacking hack')

    it 'should tell the user which teams were found', ->
      expect(@room.messages).to.eql [
        ['paolo', '@hubot find teams like hacking hack'],
        ['hubot', '@paolo Found 4 teams; here\'s a few: Hack Hackers Hacking Hacks, Hackers Hacking Hack Hacks, Another Team']
      ]
    
    after ->
      @room.destroy()

  describe 'when no matching teams found', ->
  
    before (done) ->
      @room = helper.createRoom()
        
      @findTeamsStub = sinon.stub().returns Promise.resolve
        ok: true
        teams: []
      
      @room.robot.hack24client =
        findTeams: @findTeamsStub
      
      @room.user.say('paolo', '@hubot find teams like hacking hack').then done

    it 'should tell the user that no teams were found', ->
      expect(@room.messages).to.eql [
        ['paolo', '@hubot find teams like hacking hack'],
        ['hubot', '@paolo None found.']
      ]
    
    after ->
      @room.destroy()