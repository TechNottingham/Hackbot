expect = require('chai').expect

Helper = require 'hubot-test-helper'
helper = new Helper('../scripts/hack24api.coffee')

describe 'Can see the API', ->

  describe 'hubot can see the API', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @room.robot.hack24client =
        checkApi: ->
          Promise.resolve(200)
      
      @room.user.say('bob', '@hubot can you see the api?').then done

    after ->
      @room.destroy()

    it 'should reply to the user that the API is available', ->
        expect(@room.messages).to.eql [
          ['bob', '@hubot can you see the api?'],
          ['hubot', "@bob I'll have a quick look for you Sir..."],
          ['hubot', '@bob I see her!']
        ]

  describe 'hubot is unable to see the API', ->
  
    before (done) ->
      @room = helper.createRoom()
      
      @room.robot.hack24client =
        checkApi: ->
          Promise.resolve(99)
      
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
      
      @room.robot.hack24client =
        checkApi: ->
          Promise.reject new Error('unknown')
      
      @room.user.say('bob', '@hubot can you see the api?').then done
      
    after ->
      @room.destroy()

    it 'should reply to the user that he cannot see the API because of a big problem', ->
      expect(@room.messages).to.eql [
        ['bob', '@hubot can you see the api?'],
        ['hubot', "@bob I'll have a quick look for you Sir..."],
        ['hubot', '@bob I\'m sorry Sir, there appears to be a big problem!']
      ]