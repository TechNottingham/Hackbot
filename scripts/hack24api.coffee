# Description:
#   Self service team and user administration scripts.
#
# Configuration:
#   HACK24API_URL
#
# Commands:
#   hubot can you see the api? - checks if the API is visible
#   hubot what are your prime directives? - cites hubot's prime directives
#   hubot my id - echos the ID hubot knows you as
#   hunot create team <team name> - tries to create team with name <team name> and adds you to it
#
# Author:
#   codesleuth
#

{Client} = require '../lib/client'

module.exports = (robot) ->

  robot.respond /can you see the api\??/i, (response) ->
    response.reply "I'll have a quick look for you Sir..."
    Client.checkApi robot.http, (statusCode) ->
      response.reply if statusCode is 200 then 'I see her!' else "I'm sorry Sir, there appears to be a problem; something about \"#{statusCode}\""

  robot.respond /what are your prime directives\??/i, (response) ->
    response.reply "1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"
    
  robot.respond /my id/i, (response) ->
    response.reply "Your id is #{response.message.user.id}"

  robot.respond /create team (.*)/i, (response) ->
    userId = response.message.user.id
    userName = response.message.user.name
    teamName = response.match[1]
    
    Client.getUser robot.http, userId, (statusCode, userResponse) ->
      
      if statusCode is 404
        userJson = JSON.stringify
          id: userId
        
        Client.createUser robot.http, userId, userName, (statusCode) ->
          Client.createTeam robot.http, teamName, userId, (statusCode) ->
            if statusCode is 409
              return response.reply "Sorry, but that team already exists!"
              
            response.reply "Welcome to team #{teamName}!"
            
      else
      
        if userResponse.team isnt undefined
          response.reply "You're already a member of #{userResponse.team}!"
          return
        
        Client.createTeam robot.http, teamName, userId, (statusCode) ->
          if statusCode is 409
            return response.reply "Sorry, but that team already exists!"
            
          response.reply "Welcome to team #{teamName}!"
        