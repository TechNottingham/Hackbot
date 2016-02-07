class Client

  @createTeam: (http, teamName, userId) ->
    new Promise (resolve, reject) ->
      body = JSON.stringify 
        name: teamName
        members: [ userId ]
        
      http("#{process.env.HACK24API_URL}/teams")
        .header('Content-Type', 'application/json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          resolve res.statusCode

  @createUser: (http, userId, userName) ->
    new Promise (resolve, reject) ->
      body = JSON.stringify 
        id: userId
        name: userName
          
      http("#{process.env.HACK24API_URL}/users")
        .header('Content-Type', 'application/json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          resolve res.statusCode
  
  @checkApi: (http) ->
    new Promise (resolve, reject) ->
      http("#{process.env.HACK24API_URL}/api")
        .get() (err, res, body) ->
          if err? then return reject err
          resolve(res.statusCode)
        
        
  @getUser: (http, userId) ->
    new Promise (resolve, reject) ->
      http("#{process.env.HACK24API_URL}/users/#{userId}")
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          if err? then return reject err
          resolve
            statusCode: res.statusCode
            user: if res.statusCode is 200 then JSON.parse body

module.exports.Client = Client