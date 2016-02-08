Helper = require 'hubot-test-helper'
expect = require('chai').expect

helper = new Helper('../scripts/hack24api.coffee')

describe 'My ID', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  describe 'hubot tells the user their id', ->

    it 'should reply to the user with their identifier', ->
      @room.user.say('bob', '@hubot my id').then =>
        expect(@room.messages).to.eql [
          ['bob', '@hubot my id'],
          ['hubot', "@bob Your id is bob"]
        ]
