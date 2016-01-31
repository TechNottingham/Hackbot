module.exports = (robot) ->
  robot.respond /Can you see the API?/i, (res) ->
    robot.http("http://api.hack24.co.uk/teams")
      .get() (err, res, body) ->
        if err
          res.reply "I'm sorry Sir, I cannot see her."
        res.reply "I see her!"
