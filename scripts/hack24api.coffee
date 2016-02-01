module.exports = (robot) ->

  robot.respond /can you see the api\??/i, (response) ->
    response.reply "I'll have a quick look for you Sir..."
    robot.http("http://api.hack24.co.uk/teams")
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          response.reply "I'm sorry Sir, there appears to be a problem; something about \"#{res.statusCode}\""
          return
        response.reply "I see her!"

  robot.respond /what are your prime directives\??/i, (response) ->
    response.reply "1. Serve the public trust\n2. Protect the innocent hackers\n3. Uphold the Code of Conduct\n4. [Classified]"
