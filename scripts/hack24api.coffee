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
    teamName = response.match[1]
    
    teamJSON = JSON.stringify 
      name: teamName
      members: [ userId ]
        
    robot.http("#{process.env.HACK24API_URL}/teams")
      .header('Content-Type', 'application/json')
      .post(teamJSON) (err, res, body) ->
        response.reply "Welcome to team #{teamName}!"