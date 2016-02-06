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

createTeam = (http, teamName, userId, callback) ->
  body = JSON.stringify 
    name: teamName
    members: [ userId ]
      
  http("#{process.env.HACK24API_URL}/teams")
    .header('Content-Type', 'application/json')
    .post(body) (err, res, body) ->
      callback res.statusCode

createUser = (http, userId, userName, callback) ->
  body = JSON.stringify 
    id: userId
    name: userName
      
  http("#{process.env.HACK24API_URL}/users")
    .header('Content-Type', 'application/json')
    .post(body) (err, res, body) ->
      callback res.statusCode


module.exports = (robot) ->
  robot.respond /can you see the api\??/i, (response) ->
    response.reply "I'll have a quick look for you Sir..."
    robot.http("#{process.env.HACK24API_URL}/api")
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          response.reply "I'm sorry Sir, there appears to be a problem; something about \"#{res.statusCode}\""
          return
        response.reply "I see her!"

  robot.respond /what are your prime directives\??/i, (response) ->
    response.reply "1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"
    
  robot.respond /my id/i, (response) ->
    response.reply "Your id is #{response.message.user.id}"

  robot.respond /create team (.*)/i, (response) ->
    userId = response.message.user.id
    userName = response.message.user.name
    teamName = response.match[1]
        
    robot.http("#{process.env.HACK24API_URL}/users/#{userId}")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
      
        if res.statusCode is 404
          userJson = JSON.stringify
            id: userId
          
          createUser robot.http, userId, userName, (statusCode) ->
            createTeam robot.http, teamName, userId, (statusCode) ->
              if statusCode is 409
                return response.reply "Sorry, but that team already exists!"
                
              response.reply "Welcome to team #{teamName}!"
              
        else
        
          userResponse = JSON.parse body
        
          if userResponse.team?
            response.reply "You're already a member of #{userResponse.team}!"
            return
          
          createTeam robot.http, teamName, userId, (statusCode) ->
            if statusCode is 409
              return response.reply "Sorry, but that team already exists!"
              
            response.reply "Welcome to team #{teamName}!"
        