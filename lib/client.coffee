HttpClient = require 'scoped-http-client'
{Store} = require('yayson')()

getAuth = (emailAddress) -> "#{emailAddress}:#{process.env.HACKBOT_PASSWORD}"

class Client

  constructor: (robot) ->
    @httpClient = if robot? then robot.http.bind(robot) else HttpClient.create

  createTeam: (teamName, userId, emailAddress) ->
    new Promise (resolve, reject) =>
      body = JSON.stringify 
        data:
          type: 'teams'
          attributes:
            name: teamName
          relationships:
            members:
              data: [{
                type: 'users'
                id: userId
              }]

      @httpClient("#{process.env.HACK24API_URL}/teams", { auth: getAuth(emailAddress) })
        .header('Content-Type', 'application/vnd.api+json')
        .header('Accept', 'application/vnd.api+json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          resolve 
            ok: res.statusCode == 201
            statusCode: res.statusCode

  createUser: (userId, userName, emailAddress) ->
    new Promise (resolve, reject) =>
      body = JSON.stringify 
        data:
          type: 'users'
          id: userId
          attributes:
            name: userName
      
      @httpClient("#{process.env.HACK24API_URL}/users", { auth: getAuth(emailAddress) })
        .header('Content-Type', 'application/vnd.api+json')
        .header('Accept', 'application/vnd.api+json')
        .post(body) (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          resolve
            ok: res.statusCode == 201
            statusCode: res.statusCode
  
  checkApi: ->
    new Promise (resolve, reject) =>
      @httpClient("#{process.env.HACK24API_URL}/api")
        .get() (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          resolve
            ok: res.statusCode == 200
            statusCode: res.statusCode
        
  getUser: (userId) ->
    new Promise (resolve, reject) =>
      @httpClient("#{process.env.HACK24API_URL}/users/#{userId}")
        .header('Accept', 'application/vnd.api+json')
        .get() (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          
          result =
            ok: res.statusCode == 200
            statusCode: res.statusCode
            
          if result.ok
            store = new Store
            user = store.sync JSON.parse(body)
            result.user = user
              
          resolve(result)
        
  getTeam: (teamId) ->
    new Promise (resolve, reject) =>
      @httpClient("#{process.env.HACK24API_URL}/teams/#{encodeURIComponent(teamId)}")
        .header('Accept', 'application/vnd.api+json')
        .get() (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          
          result =
            ok: res.statusCode == 200
            statusCode: res.statusCode
            
          if result.ok
            store = new Store
            team = store.sync JSON.parse(body)
            result.team = team
              
          resolve(result)
        
  removeTeamMember: (teamId, userId, emailAddress) ->
    new Promise (resolve, reject) =>
      body = JSON.stringify 
        data: [{
          type: 'users'
          id: userId
        }]
        
      @httpClient("#{process.env.HACK24API_URL}/teams/#{encodeURIComponent(teamId)}/members", { auth: getAuth(emailAddress) })
        .header('Accept', 'application/vnd.api+json')
        .header('Content-Type', 'application/vnd.api+json')
        .delete(body) (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          
          result =
            ok: res.statusCode == 204
            statusCode: res.statusCode
            
          resolve(result)
        
  findTeams: (filter) ->
    new Promise (resolve, reject) =>
      @httpClient("#{process.env.HACK24API_URL}/teams?filter[name]=#{encodeURIComponent(filter)}")
        .header('Accept', 'application/vnd.api+json')
        .get() (err, res, body) ->
          if err? then return reject err
          if res.statusCode is 403 then return reject(new Error 'Forbidden')
          
          result =
            ok: res.statusCode == 200
            statusCode: res.statusCode
            
          if result.ok
            store = new Store
            result.teams = store.sync JSON.parse(body)
              
          resolve(result)

module.exports.Client = Client