class Client

  @createTeam: (http, teamName, userId, callback) ->
    body = JSON.stringify 
      name: teamName
      members: [ userId ]
      
    http("#{process.env.HACK24API_URL}/teams")
      .header('Content-Type', 'application/json')
      .post(body) (err, res, body) ->
        callback res.statusCode

  @createUser: (http, userId, userName, callback) ->
    body = JSON.stringify 
      id: userId
      name: userName
        
    http("#{process.env.HACK24API_URL}/users")
      .header('Content-Type', 'application/json')
      .post(body) (err, res, body) ->
        callback res.statusCode
  
  @checkApi: (http, callback) ->
    http("#{process.env.HACK24API_URL}/api")
      .get() (err, res, body) ->
        callback res.statusCode
        
  @getUser: (http, userId, callback) ->
    http("#{process.env.HACK24API_URL}/users/#{userId}")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        callback res.statusCode, if res.statusCode is 200 then JSON.parse body

module.exports.Client = Client