getAuth = () -> "#{process.env.HACKBOT_USERNAME}:#{process.env.HACKBOT_PASSWORD}"

class Client

  constructor: (@robot) ->

  createTeam: (teamName, userId) =>
    new Promise (resolve, reject) =>
      body = JSON.stringify 
        name: teamName
        members: [ userId ]
        
      @robot.http("#{process.env.HACK24API_URL}/teams", { auth: getAuth() })
        .header('Content-Type', 'application/json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          resolve res.statusCode

  createUser: (userId, userName) =>
    new Promise (resolve, reject) =>
      body = JSON.stringify 
        userid: userId
        name: userName
          
      @robot.http("#{process.env.HACK24API_URL}/users", { auth: getAuth() })
        .header('Content-Type', 'application/json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          resolve res.statusCode
  
  checkApi: =>
    new Promise (resolve, reject) =>
      @robot.http("#{process.env.HACK24API_URL}/api")
        .get() (err, res, body) ->
          if err? then return reject err
          resolve(res.statusCode)
        
  getUser: (userId) =>
    new Promise (resolve, reject) =>
      @robot.http("#{process.env.HACK24API_URL}/users/#{userId}")
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          if err? then return reject err
          result = { statusCode: res.statusCode }
          if res.statusCode is 200 then result.user = JSON.parse(body)
          resolve(result)
        
  getTeam: (teamId) =>
    new Promise (resolve, reject) =>
      @robot.http("#{process.env.HACK24API_URL}/teams/#{encodeURIComponent(teamId)}")
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          if err? then return reject err
          result = { statusCode: res.statusCode }
          if res.statusCode is 200 then result.team = JSON.parse(body)
          resolve(result)

module.exports.Client = Client