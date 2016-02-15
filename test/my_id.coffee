Helper = require 'hubot-test-helper'
expect = require('chai').expect

helper = new Helper('../scripts/hack24api.coffee')

describe '@hubot my id', ->

  before ->
    @room = helper.createRoom()

  after ->
    @room.destroy()

  it 'should tell the user their identifier', ->
    @room.user.say('bob', '@hubot my id').then =>
      expect(@room.messages).to.eql [
        ['bob', '@hubot my id'],
        ['hubot', "@bob Your id is bob"]
      ]
