module.exports = (robot) ->
  robot.respond /Can you see the API?/i, (response) ->
    robot.http("http://api.hack24.co.uk/teams")
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          response.reply "I'm sorry Sir, I cannot see her."
          return
        response.reply "I see her!"
