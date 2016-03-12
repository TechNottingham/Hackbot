chai = require 'chai'
expect = chai.expect

{Client} = require '../lib/client'

express = require 'express'

apiJsonParser = require('body-parser').json
  type: 'application/vnd.api+json'

describe 'Hack24 API Client', ->

  describe '#checkApi', ->
    
    describe 'when request succeeds', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        api = express()

        api.get '/api', (req, res) =>
          res.status(200).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.checkApi() 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 200 OK', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true
  
    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.use (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.checkApi('some team', 'some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
          expect(@err.message).to.equal('socket hang up')


  describe '#createTeam', ->
  
    describe 'when request succeeds', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = '65456465464654'
        
        api = express()
        
        @teamName = 'Pineapple Express'
        @userId = 'U12345'
        email_address = 'some@guy.com'
        
        @expectedAuth = "Basic #{new Buffer("#{email_address}:#{pass}").toString('base64')}"
        
        api.post '/teams', apiJsonParser, (req, res) =>
          @contentType = req.headers['content-type']
          @accept = req.headers['accept']
          @authorization = req.headers['authorization']
          @body = req.body
          res.status(201).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createTeam(@teamName, @userId, email_address) 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 201 Created', ->
          expect(@result.statusCode).to.equal(201)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should request with content-type application/vnd.api+json', ->
          expect(@contentType).to.equal('application/vnd.api+json')

      it 'should request with the expected authorization', ->
          expect(@authorization).to.equal(@expectedAuth)

      it 'should request to create the expected team', ->
          expect(@body.data.type).to.equal('teams')
          expect(@body.data.attributes.name).to.equal(@teamName)

      it 'should request to add the user relationship', ->
          expect(@body.data.relationships.members.data.length).to.equal(1)
          expect(@body.data.relationships.members.data[0].type).to.equal('users')
          expect(@body.data.relationships.members.data[0].id).to.equal(@userId)

    describe 'when team exists', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.post '/teams', apiJsonParser, (req, res) =>
          @body = req.body
          res.status(409).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createTeam('Pineapple Express', 'U12345') 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 409 Conflict', ->
          expect(@result.statusCode).to.equal(409)

      it 'should resolve with not OK', ->
          expect(@result.ok).to.be.false
  
    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.post '/teams', (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createTeam('some team', 'some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#getUser', ->

    describe 'when user exists and in a team', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        @userId = 'U12345'
        @userName = 'Barry'
        @teamId = 'clicky-keys'
        @teamName = 'Clicky Keys'
        @otherUserId = 'U67890'
        @otherUserName = 'Zackary'
        
        api.get "/users/#{@userId}", (req, res) =>
          @accept = req.headers['accept']
          res.status(200).send
            data:
              type: 'users'
              id: @userId
              attributes:
                name: @userName
              relationships:
                team:
                  data:
                    type: 'teams'
                    id: @teamId
            included: [{
              type: 'teams'
              id: @teamId
              attributes:
                name: @teamName
              relationships:
                members:
                  data: [{
                    type: 'users'
                    id: @userId
                  },{
                    type: 'users'
                    id: @otherUserId
                  }]
            },{
              type: 'users'
              id: @otherUserId
              attributes:
                name: @otherUserName
              relationships:
                team:
                  data:
                    type: 'teams'
                    id: @teamId
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getUser(@userId)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 200 OK', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should return the expected user', ->
          expect(@result.user.id).to.equal(@userId)
          expect(@result.user.name).to.equal(@userName)

      it 'should return the expected team relationship', ->
          expect(@result.user.team.id).to.equal(@teamId)
          expect(@result.user.team.name).to.equal(@teamName)
          expect(@result.user.team.members.length).to.equal(2)
          expect(@result.user.team.members[0].id).to.equal(@userId)
          expect(@result.user.team.members[0].name).to.equal(@userName)
          expect(@result.user.team.members[1].id).to.equal(@otherUserId)
          expect(@result.user.team.members[1].name).to.equal(@otherUserName)

    describe 'when user exists and not in a team', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        @userId = 'U12345'
        @userName = 'Barry'
        
        api.get "/users/#{@userId}", (req, res) =>
          @accept = req.headers['accept']
          res.status(200).send
            data:
              type: 'users'
              id: @userId
              attributes:
                name: @userName
              relationships:
                team:
                  data: null
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getUser(@userId)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 200 OK', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should return the expected user', ->
          expect(@result.user.id).to.equal(@userId)
          expect(@result.user.name).to.equal(@userName)

      it 'should return a null team', ->
          expect(@result.user.team).to.equal(null)

    describe 'when user does not exist', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.get "/users/#{@userId}", (req, res) =>
          res.status(404).send
            errors: [{
              status: '404'
              title: 'Resource not found.'
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getUser('U12345')
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 404 Not Found', ->
          expect(@result.statusCode).to.equal(404)

      it 'should resolve with not OK', ->
          expect(@result.ok).to.be.false

      it 'should resolve without setting the user', ->
          expect(@result.user).to.equal(undefined)

    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.get '/users/:userId', (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getUser('some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#getTeam', ->

    describe 'when team exists', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        @teamId = 'clicky-keys'
        @teamName = 'Clicky Keys'
        @firstUserId = 'U12345'
        @firstUserName = 'Barry'
        @secondUserId = 'U67890'
        @secondUserName = 'Zackary'
        
        api.get "/teams/#{@teamId}", (req, res) =>
          @accept = req.headers['accept']
          res.status(200).send
            data:
              type: 'teams'
              id: @teamId
              attributes:
                name: @teamName
              relationships:
                members:
                  data: [{
                    type: 'users'
                    id: @firstUserId
                  },{
                    type: 'users'
                    id: @secondUserId
                  }]
            included: [{
              type: 'users'
              id: @firstUserId
              attributes:
                name: @firstUserName
              relationships:
                team:
                  data: {
                    type: 'teams'
                    id: @teamId
                  }
            },{
              type: 'users'
              id: @secondUserId
              attributes:
                name: @secondUserName
              relationships:
                team:
                  data: {
                    type: 'teams'
                    id: @teamId
                  }
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getTeam(@teamId)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 200 OK', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should return the expected team', ->
          expect(@result.team.id).to.equal(@teamId)
          expect(@result.team.name).to.equal(@teamName)

      it 'should return the expected members relationships', ->
          expect(@result.team.members.length).to.equal(2)
          expect(@result.team.members[0].id).to.equal(@firstUserId)
          expect(@result.team.members[0].name).to.equal(@firstUserName)
          expect(@result.team.members[1].id).to.equal(@secondUserId)
          expect(@result.team.members[1].name).to.equal(@secondUserName)

    describe 'when team does not exist', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.get '/teams/:teamId', (req, res) =>
          res.status(404).send
            errors: [{
              status: '404'
              title: 'Resource not found.'
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getTeam('some team')
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 404 Not Found', ->
          expect(@result.statusCode).to.equal(404)

      it 'should resolve with not OK', ->
          expect(@result.ok).to.be.false

      it 'should resolve without setting the team', ->
          expect(@result.team).to.equal(undefined)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.get '/teams/:teamId', (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.getTeam('some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#createUser', ->

    describe 'when created successfully', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = 'slkjfsjkfjks'
        
        api = express()
        
        @userId = 'U12345'
        @userName = 'Pineapple Express'
        email_address = 'lkjasdkljasd@gfhjdgf.daskjd'
        
        @expectedAuth = "Basic #{new Buffer("#{email_address}:#{pass}").toString('base64')}"
        
        api.post '/users', apiJsonParser, (req, res) =>
          @contentType = req.headers['content-type']
          @accept = req.headers['accept']
          @authorization = req.headers['authorization']
          @body = req.body
          res.status(201).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createUser(@userId, @userName, email_address) 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 201 Created', ->
          expect(@result.statusCode).to.equal(201)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should request with content-type application/vnd.api+json', ->
          expect(@contentType).to.equal('application/vnd.api+json')

      it 'should request with the expected authorization', ->
          expect(@authorization).to.equal(@expectedAuth)

      it 'should request to create the expected user', ->
          expect(@body.data.type).to.equal('users')
          expect(@body.data.id).to.equal(@userId)
          expect(@body.data.attributes.name).to.equal(@userName)

    describe 'when user exists', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.post '/users', apiJsonParser, (req, res) =>
          res.status(409).send
            errors: [{
              status: '409',
              title: 'Resource ID already exists.'
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createUser('raghght', 'Alien Race') 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 409 Conflict', ->
          expect(@result.statusCode).to.equal(409)

      it 'should resolve with not OK', ->
          expect(@result.ok).to.be.false
          
    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.use (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.createUser('some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#removeTeamMember', ->
  
    describe 'when request succeeds', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = 'sky'
        
        api = express()
        
        @teamId = 'swan-song'
        @userId = 'U12345'
        emailAddress = 'asdas@asd0-9098'
        
        @expectedAuth = "Basic #{new Buffer("#{emailAddress}:#{pass}").toString('base64')}"
        
        api.delete "/teams/#{@teamId}/members", apiJsonParser, (req, res) =>
          @contentType = req.headers['content-type']
          @accept = req.headers['accept']
          @authorization = req.headers['authorization']
          @body = req.body
          res.status(204).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.removeTeamMember(@teamId, @userId, emailAddress) 
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 204 No Content', ->
          expect(@result.statusCode).to.equal(204)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should request with content-type application/vnd.api+json', ->
          expect(@contentType).to.equal('application/vnd.api+json')

      it 'should request with the expected authorization', ->
          expect(@authorization).to.equal(@expectedAuth)

      it 'should request only one resource object to be removed', ->
          expect(@body.data.length).to.equal(1)

      it 'should request that a user be removed', ->
          expect(@body.data[0].type).to.equal('users')

      it 'should request the expected user to be removed', ->
          expect(@body.data[0].id).to.equal(@userId)
          
    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.use (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.removeTeamMember('some team', 'some user') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#findTeams', ->

    describe 'when teams found', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        @filter = 'hacking hack'
        @firstTeam =
          id: 'hack-hackers-hacking-hacks'
          name: 'Hack Hackers Hacking Hacks'
        @secondTeam =
          id: 'hackers-hacking-hack-hacks'
          name: 'Hackers Hacking Hack Hacks'
          
        
        api.get "/teams", (req, res) =>
          @accept = req.headers['accept']
          @filterNameValue = req.query.filter.name
          res.status(200).send
            data: [{
              type: 'teams'
              id: @firstTeam.id
              attributes:
                name: @firstTeam.name
            },{
              type: 'teams'
              id: @secondTeam.id
              attributes:
                name: @secondTeam.name
            }]
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.findTeams(@filter)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 200 OK', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with OK', ->
          expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
          expect(@accept).to.equal('application/vnd.api+json')

      it 'should return two teams', ->
          expect(@result.teams.length).to.equal(2)

      it 'should return both teams', ->
          expect(@result.teams[0].id).to.equal(@firstTeam.id)
          expect(@result.teams[0].name).to.equal(@firstTeam.name)
          expect(@result.teams[1].id).to.equal(@secondTeam.id)
          expect(@result.teams[1].name).to.equal(@secondTeam.name)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.get '/teams', (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.findTeams('some filter') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#addUserToTeam', ->
    
    describe 'when succeeds', ->
      
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = 'slkjfsjkfjks'
        
        api = express()
        
        @userId = 'U12345'
        @userName = 'Pineapple Dicxpress'
        @teamId = 'fruity'
        email_address = 'lkjasdkljasd@gfhjdgf.daskjd'
        
        @expectedAuth = "Basic #{new Buffer("#{email_address}:#{pass}").toString('base64')}"
        
        api.post '/teams/:teamId/members', apiJsonParser, (req, res) =>
          @contentType = req.headers['content-type']
          @accept = req.headers['accept']
          @authorization = req.headers['authorization']
          @body = req.body
          @teamIdParam = req.params.teamId
          res.status(201).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.addUserToTeam(@teamId, @userId, email_address)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 201 Created', ->
        expect(@result.statusCode).to.equal(201)

      it 'should resolve with OK', ->
        expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
        expect(@accept).to.equal('application/vnd.api+json')

      it 'should request with content-type application/vnd.api+json', ->
        expect(@contentType).to.equal('application/vnd.api+json')

      it 'should request with the expected authorization', ->
        expect(@authorization).to.equal(@expectedAuth)

      it 'should request with the expected team ID', ->
        expect(@teamIdParam).to.equal(@teamId)

      it 'should request to create the expected user', ->
        expect(@body.data[0].type).to.equal('users')
        expect(@body.data[0].id).to.equal(@userId)
          
    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.use (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.addUserToTeam('some team', 'some user', 'some email') 
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')


  describe '#updateMotto', ->
    
    describe 'when team exists', ->
      
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = 'slkjfsjkfjks'
        
        api = express()
        
        @motto = 'No TV and no beer make Homer something something'
        @teamId = 'duff'
        email_address = 'lkjasdkljasd@gfhjdgf.daskjd'
        
        @expectedAuth = "Basic #{new Buffer("#{email_address}:#{pass}").toString('base64')}"
        
        api.patch '/teams/:teamId', apiJsonParser, (req, res) =>
          @contentType = req.headers['content-type']
          @accept = req.headers['accept']
          @authorization = req.headers['authorization']
          @body = req.body
          @teamIdParam = req.params.teamId
          res.status(204).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.updateMotto(@motto, @teamId, email_address)
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 204 No Content', ->
        expect(@result.statusCode).to.equal(204)

      it 'should resolve with OK', ->
        expect(@result.ok).to.be.true

      it 'should request with accept application/vnd.api+json', ->
        expect(@accept).to.equal('application/vnd.api+json')

      it 'should request with content-type application/vnd.api+json', ->
        expect(@contentType).to.equal('application/vnd.api+json')

      it 'should request with the expected authorization', ->
        expect(@authorization).to.equal(@expectedAuth)

      it 'should request with the expected team ID', ->
        expect(@teamIdParam).to.equal(@teamId)

      it 'should request to update the expected team', ->
        expect(@body.data.type).to.equal('teams')
        expect(@body.data.id).to.equal(@teamId)
    
    describe 'when team not found', ->
      
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        pass = process.env.HACKBOT_PASSWORD = 'slkjfsjkfjks'
        
        api = express()
        
        email_address = 'lkjasdkljasd@gfhjdgf.daskjd'
        
        api.patch '/teams/:teamId', apiJsonParser, (req, res) =>
          res.status(404).send()
        
        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.updateMotto('chips', 'fish', 'alkjdajh@sfdsdf.co.uk')
            .then (@result) =>
              done()
            .catch done
      
      after (done) ->
        @server.close done

      it 'should resolve with status code 404 Not Found', ->
        expect(@result.statusCode).to.equal(404)

      it 'should resolve with not OK', ->
        expect(@result.ok).to.be.false

    describe 'when request errors', ->
  
      before (done) ->
        process.env.HACK24API_URL = 'http://localhost:12345'
        
        api = express()
        
        api.use (req, res) ->
          res.socket.destroy()

        client = new Client
        
        @server = api.listen 12345, (err) =>
          client.updateMotto('some motto', 'some team id', 'some email address')
            .then ->
              done(new Error 'Promise resolved')
            .catch (@err) =>
              done()
      
      after (done) ->
        @server.close done

      it 'should reject with an error', ->
        expect(@err.message).to.equal('socket hang up')
