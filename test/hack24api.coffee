Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../scripts/hack24api.coffee')

describe 'hack24api script', ->
  beforeEach ->
    @room = helper.createRoom()
    @robot =
      respond: sinon.spy()
      http: sinon.spy()

  afterEach ->
    @room.destroy()

#   it 'can see the hack24 api', ->
#     @room.user.say('alice', 'can you see the api?').then =>
#       expect(@room.messages).to.eql [
#         ['alice', 'did someone call for a badger?']
#         ['hubot', 'Badgers? BADGERS? WE DON\'T NEED NO STINKIN BADGERS']
#       ]
# 
#   it 'won\'t open the pod bay doors', ->
#     @room.user.say('bob', '@hubot open the pod bay doors').then =>
#       expect(@room.messages).to.eql [
#         ['bob', '@hubot open the pod bay doors']
#         ['hubot', '@bob I\'m afraid I can\'t let you do that.']
#       ]
# 
#   it 'will open the dutch doors', ->
#     @room.user.say('bob', '@hubot open the dutch doors').then =>
#       expect(@room.messages).to.eql [
#         ['bob', '@hubot open the dutch doors']
#         ['hubot', '@bob Opening dutch doors']
#       ]