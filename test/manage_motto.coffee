chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot our motto is', ->

  describe 'when team exists with permission', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'
      @userEmail = 'jerry@jerry.jerry'
      @teamId = 'my-crazy-team-name'
      @teamName = 'My Crazy Team Name'

      @room.robot.brain.data.users[@userId] = email_address: @userEmail

      @updateMottoStub = sinon.stub().returns Promise.resolve
        ok: true
        statusCode: 200
        team:
          id: @teamId
          name: @teamName
          motto: 'We are great'
          members: [{
            id: 'user1'
            name: 'John'
          },{
            id: 'user2'
            name: 'Barry'
          }]

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: @teamId
            name: @teamName

      @room.robot.hack24client =
        getUser: @getUserStub
        updateMotto: @updateMottoStub

      @room.user.say(@userId, '@hubot our motto is We are great').then done

    it 'should update the motto on the API', ->
      expect(@updateMottoStub).to.have.been.calledWith('We are great',@teamId,@userId,@userEmail)

    it 'should tell the user the motto is changed', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot our motto is We are great'],
        ['hubot', '@' + @userId + ' So it is! As My Crazy Team Name say: We are great!']
      ]
    after ->
      @room.destroy()
describe 'when team exists without permission', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'
      @userEmail = 'jerry@jerry.jerry'
      @teamId = 'my-crazy-team-name'
      @teamName = 'My Crazy Team Name'

      @room.robot.brain.data.users[@userId] = email_address: @userEmail

      @updateMottoStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 403

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: @teamId
            name: @teamName

      @room.robot.hack24client =
        getUser: @getUserStub
        updateMotto: @updateMottoStub

      @room.user.say(@userId, '@hubot our motto is We are great').then done

    it 'should update the motto on the API', ->
      expect(@updateMottoStub).to.have.been.calledWith('We are great',@teamId,@userId,@userEmail)

    it 'should tell the user the motto is changed', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot our motto is We are great'],
        ['hubot', '@' + @userId + ' Sorry, only team members can change the motto.']
      ]
    after ->
      @room.destroy()
  describe 'when team does not exist', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'
      @userEmail = 'jerry@jerry.jerry'

      @room.robot.brain.data.users[@userId] = email_address: @userEmail

      @updateMottoStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          team:
            id: undefined

      @room.robot.hack24client =
        getUser: @getUserStub
        updateMotto: @updateMottoStub

      @room.user.say(@userId, '@hubot our motto is We are great').then done

    it 'should tell the user the motto is changed', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot our motto is We are great'],
        ['hubot', '@' + @userId + ' You\'re not in a team! :goberserk:']
      ]
    after ->
      @room.destroy()
