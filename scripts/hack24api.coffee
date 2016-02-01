module.exports = (robot) ->
  robot.respond /Can you see the API?/i, (response) ->
    robot.http("http://api.hack24.co.uk/teams")
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          response.reply "I'm sorry Sir, I cannot see her."
          return
        response.reply "I see her!"
  robot.respond /.*[your prime directives?]$/i, (response) ->
    response.reply "1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"
