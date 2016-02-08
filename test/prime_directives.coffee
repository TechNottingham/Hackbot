Helper = require 'hubot-test-helper'
expect = require('chai').expect

helper = new Helper('../scripts/hack24api.coffee')

describe 'Prime directives', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()
    
  describe 'hubot cites his prime directives', ->

    it 'should reply to the user the prime directives', ->
      @room.user.say('bob', '@hubot what are your prime directives?').then =>
        expect(@room.messages).to.eql [
          ['bob', '@hubot what are your prime directives?'],
          ['hubot', "@bob 1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"]
        ]