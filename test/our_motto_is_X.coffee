chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot our motto is X', ->

  describe 'when user in a team', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'
      @userEmail = 'jerry@jerry.jerry'
      @teamId = 'my-crazy-team-name'
      @teamName = 'My Crazy Team Name'
      @motto = 'We are great'

      @room.robot.brain.data.users[@userId] = email_address: @userEmail

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team:
            id: @teamId
            name: @teamName

      @updateMottoStub = sinon.stub().returns Promise.resolve
        ok: true

      @room.robot.hack24client =
        getUser: @getUserStub
        updateMotto: @updateMottoStub

      @room.user.say(@userId, "@hubot our motto is #{@motto}").then done

    it 'should fetch the user', ->
      expect(@getUserStub).to.have.been.calledWith(@userId)

    it 'should update the team motto', ->
      expect(@updateMottoStub).to.have.been.calledWith(@motto, @teamId, @userEmail)

    it 'should tell the user the new motto', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot our motto is #{@motto}"],
        ['hubot', "@#{@userId} So it is! As #{@teamName} say: #{@motto}"]
      ]

    after ->
      @room.destroy()

  describe 'when team exists without permission', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'
      @motto = 'We are great'

      @room.robot.brain.data.users[@userId] = email_address: 'jerry@jerry.jerry'

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team:
            id: 'my-crazy-team-name'

      @updateMottoStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 403

      @room.robot.hack24client =
        getUser: @getUserStub
        updateMotto: @updateMottoStub

      @room.user.say(@userId, "@hubot our motto is #{@motto}").then done

    it 'should tell the user they do not have permission', ->
      expect(@room.messages).to.eql [
        [@userId, "@hubot our motto is #{@motto}"],
        ['hubot', "@#{@userId} Sorry, only team members can change the motto."]
      ]

    after ->
      @room.destroy()

  describe 'when user not in a team', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'

      @room.robot.brain.data.users[@userId] = email_address: 'jerry@jerry.jerry'

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: true
        user:
          id: @userId
          team: null

      @room.robot.hack24client =
        getUser: @getUserStub

      @room.user.say(@userId, '@hubot our motto is We are great').then done

    it 'should tell the user the motto is changed', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot our motto is We are great'],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]

    after ->
      @room.destroy()

  describe 'when user unknown', ->

    before (done) ->
      @room = helper.createRoom()
      @userId = 'jerry'

      @room.robot.brain.data.users[@userId] = email_address: 'jerry@jerry.jerry'

      @getUserStub = sinon.stub().returns Promise.resolve
        ok: false
        statusCode: 404

      @room.robot.hack24client =
        getUser: @getUserStub

      @room.user.say(@userId, '@hubot our motto is We are great').then done

    it 'should tell the user the motto is changed', ->
      expect(@room.messages).to.eql [
        [@userId, '@hubot our motto is We are great'],
        ['hubot', "@#{@userId} You're not in a team! :goberserk:"]
      ]

    after ->
      @room.destroy()
