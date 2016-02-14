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
#   hubot create team <team name> - tries to create team with name <team name> and adds you to it
#
# Author:
#   codesleuth
#

{Client} = require '../lib/client'
slug = require 'slug'

module.exports = (robot) ->

  robot.hack24client = new Client robot

  robot.respond /can you see the api\??/i, (response) =>
    response.reply "I'll have a quick look for you Sir..."
    robot.hack24client.checkApi()
      .then (statusCode) ->
        response.reply if statusCode is 200 then 'I see her!' else "I'm sorry Sir, there appears to be a problem; something about \"#{statusCode}\""
      .catch (err) ->
        response.reply 'I\'m sorry Sir, there appears to be a big problem!'

  robot.respond /what are your prime directives\??/i, (response) ->
    response.reply "1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"
    
  robot.respond /my id/i, (response) ->
    response.reply "Your id is #{response.message.user.id}"

  robot.respond /create team (.*)/i, (response) ->
    userId = response.message.user.id
    userName = response.message.user.name
    teamName = response.match[1]
    
    robot.hack24client.getUser(userId)
      .then (res) ->
      
        if res.statusCode is 404
          robot.hack24client.createUser(userId, userName)
            .then (statusCode) ->
              if statusCode isnt 201
                return response.reply 'Sorry, I can\'t create your user account :frowning:'
                
              robot.hack24client.createTeam(teamName, userId)
                .then (statusCode) ->
                  if statusCode is 409
                    return response.reply 'Sorry, but that team already exists!'
                    
                  if statusCode isnt 201
                    return response.reply 'Sorry, I can\'t create your team :frowning:'
                    
                  response.reply "Welcome to team #{teamName}!"
          return
              
        if res.user.team isnt undefined
          response.reply "You're already a member of #{res.user.team}!"
          return
        
        robot.hack24client.createTeam(teamName, userId)
          .then (statusCode) ->
            if statusCode is 409
              return response.reply "Sorry, but that team already exists!"
                  
            if statusCode isnt 201
              return response.reply 'Sorry, I can\'t create your team :frowning:'
              
            response.reply "Welcome to team #{teamName}!"

  robot.respond /tell me about team (.*)/i, (response) ->
    teamName = slug(response.match[1])
        
    robot.hack24client.getTeamByName(teamName)
      .then (res) ->
        memberNamesPromises = for member in res.team.members
          robot.hack24client.getUser(member)
          
        Promise.all(memberNamesPromises)
          .then (results) ->
            memberList = for userResult in results
              "#{userResult.user.name}"
            response.reply "\"#{res.team.name}\" has #{res.team.members.length} members: #{memberList.join(', ')}" 
      .catch (err) ->
        response.reply 'I\'m sorry Sir, there appears to be a big problem!'