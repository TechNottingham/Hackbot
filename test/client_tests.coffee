chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai

{Client} = require '../lib/client'

describe 'Hack24 API Client', ->

  describe '#checkApi', ->

    describe 'when successfully connected', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'https://api.hack24.com'
        
        getExec = sinon.stub()
        get = sinon.stub().returns(getExec)
        getExec.callsArgWith(0, null, { statusCode: 200 }, null)
        
        @http = sinon.stub()
        @http.returns { get: get }
        
        client = new Client { http: @http }
        
        promise = client.checkApi()
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should check the API is available', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/api")

      it 'should resolve with status code 200', ->
          expect(@result).to.equal(200)


    describe 'when http error', ->
    
      before (done) ->
        apiUrl = process.env.HACK24API_URL = 'cake://api.hack24.com'
        
        @httpError = new Error('an error')
        
        getExec = sinon.stub().callsArgWith(0, @httpError, null, null)
        get = sinon.stub().returns(getExec)
        
        http = sinon.stub()
        http.returns { get: get }
        
        client = new Client { http: http }
        
        promise = client.checkApi()
        promise.then -> done()
        promise.catch (err) =>
          @err = err
          done()

      it 'should reject with the error', ->
          expect(@err).to.equal(@httpError)


  describe '#createTeam', ->

    describe 'when created successfully', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'https://api.soverytired.com'
        
        @user = process.env.HACKBOT_USERNAME = 'some adasdasd'
        @pass = process.env.HACKBOT_PASSWORD = 'a dfdgdgd'
        
        postExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 201 }, null)
        @postStub = sinon.stub().returns postExecStub
        
        @postHeadersStub = sinon.stub().returns { post: @postStub }
        
        @http = sinon.stub()
        @http.returns { header: @postHeadersStub }
        
        client = new Client { http: @http }
        
        promise = client.createTeam 'Pineapple Express', 'U12345' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should create the http client for the teams URL with the expected authentication', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/teams", sinon.match({ auth: "#{@user}:#{@pass}" }))
          
      it 'should create the team with this user as the only member', ->
          expect(@postHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
          expect(@postStub).to.have.been.calledWith('{"name":"Pineapple Express","members":["U12345"]}')

      it 'should resolve with status code 201', ->
          expect(@result).to.equal(201)

    describe 'when team exists', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'https://api.hack24.de'
        
        process.env.HACKBOT_USERNAME = 'some adasdasd'
        process.env.HACKBOT_PASSWORD = 'a dfdgdgd'
        
        postExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 409 }, null)
        postStub = sinon.stub().returns postExecStub 
        
        postHeadersStub = sinon.stub().returns { post: postStub }
        
        http = sinon.stub()
        http.returns { header: postHeadersStub }
        
        client = new Client { http: http }
        
        promise = client.createTeam 'Pineapple Express', 'U12345' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should resolve with status code 409', ->
          expect(@result).to.equal(409)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'https://api.nottinghamhackers.com'
        
        process.env.HACKBOT_USERNAME = 'some adasdasd'
        process.env.HACKBOT_PASSWORD = 'a dfdgdgd'
        
        @httpError = new Error('an error')
        
        postExecStub = sinon.stub().callsArgWith(0, @httpError, null, null)
        postStub = sinon.stub().returns postExecStub 
        
        postHeadersStub = sinon.stub().returns { post: postStub }
        
        http = sinon.stub()
        http.returns { header: postHeadersStub }
        
        client = new Client { http: http }
        
        promise = client.createTeam 'Pineapple Express', 'U12345'
        promise.then -> done()
        promise.catch (err) =>
          @err = err
          done()

      it 'should reject with the error', ->
          expect(@err).to.equal(@httpError)


  describe '#getUser', ->

    describe 'when user exists', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'http://hack24api.url'
        
        userResponse = JSON.stringify
          userid: 'U12345'
          name: 'Barry'
          team: 'Pineapple Express'
        
        getExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 200 }, userResponse)
        @getStub = sinon.stub().returns getExecStub
        
        @headerStub = sinon.stub().returns { get: @getStub }
        
        @http = sinon.stub()
        @http.returns { header: @headerStub }
        
        client = new Client { http: @http }
        
        promise = client.getUser 'U12345' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should get the user from the API', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/users/U12345")
          expect(@headerStub).to.have.been.calledWith('Accept', 'application/json')

      it 'should resolve with status code 200', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with the user', ->
          expect(@result.user.userid).to.equal('U12345')
          expect(@result.user.name).to.equal('Barry')
          expect(@result.user.team).to.equal('Pineapple Express')

    describe 'when user does not exist', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://hack24api.url'
        
        getExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 404 }, null)
        getStub = sinon.stub().returns getExecStub
        
        headerStub = sinon.stub().returns { get: getStub }
        
        http = sinon.stub()
        http.returns { header: headerStub }
        
        client = new Client { http: http }
        
        promise = client.getUser 'U67890'
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should resolve with status code 404', ->
          expect(@result.statusCode).to.equal(404)

      it 'should resolve without setting the user', ->
          expect(@result.user).to.equal(undefined)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'a url for the API!?'
        
        @httpError = new Error('an error')
        
        getExecStub = sinon.stub().callsArgWith(0, @httpError, null, null)
        getStub = sinon.stub().returns getExecStub
        
        headerStub = sinon.stub().returns { get: getStub }
        
        http = sinon.stub()
        http.returns { header: headerStub }
        
        client = new Client { http: http }
        
        promise = client.getUser 'U67890'
        promise.then -> done()
        promise.catch (err) =>
          @err = err
          done()

      it 'should reject with the error', ->
          expect(@err).to.equal(@httpError)


  describe '#getTeam', ->

    describe 'when team exists', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'http://hack24api.url'
        
        teamResponse = JSON.stringify
          name: 'Top Bants'
          members: ['U10293', 'U56473']
        
        getExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 200 }, teamResponse)
        @getStub = sinon.stub().returns getExecStub
        
        @headerStub = sinon.stub().returns { get: @getStub }
        
        @http = sinon.stub()
        @http.returns { header: @headerStub }
        
        client = new Client { http: @http }
        
        promise = client.getTeam 'top-bants' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should get the team from the API', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/teams/top-bants")
          expect(@headerStub).to.have.been.calledWith('Accept', 'application/json')

      it 'should resolve with status code 200', ->
          expect(@result.statusCode).to.equal(200)

      it 'should resolve with the team', ->
          expect(@result.team.name).to.equal('Top Bants')
          expect(@result.team.members).to.eql(['U10293', 'U56473'])

    describe 'when team does not exist', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'http://hack24api.url'
        
        getExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 404 }, null)
        getStub = sinon.stub().returns getExecStub
        
        headerStub = sinon.stub().returns { get: getStub }
        
        http = sinon.stub()
        http.returns { header: headerStub }
        
        client = new Client { http: http }
        
        promise = client.getTeam 'keyboard-kippers'
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should resolve with status code 404', ->
          expect(@result.statusCode).to.equal(404)

      it 'should resolve without setting the team', ->
          expect(@result.team).to.equal(undefined)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'https://api.hack24.com'
        
        @httpError = new Error('an error')
        
        getExecStub = sinon.stub().callsArgWith(0, @httpError, null, null)
        getStub = sinon.stub().returns getExecStub
        
        headerStub = sinon.stub().returns { get: getStub }
        
        http = sinon.stub()
        http.returns { header: headerStub }
        
        client = new Client { http: http }
        
        promise = client.getTeam 'sreppots-stoppers'
        promise.then -> done()
        promise.catch (err) =>
          @err = err
          done()

      it 'should reject with the error', ->
          expect(@err).to.equal(@httpError)


  describe '#createUser', ->

    describe 'when created successfully', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'https://api.youneedsleep.com'
        
        @user = process.env.HACKBOT_USERNAME = 'banjo jo'
        @pass = process.env.HACKBOT_PASSWORD = 'windows'
        
        postExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 201 }, null)
        @postStub = sinon.stub().returns postExecStub
        
        @postHeadersStub = sinon.stub().returns { post: @postStub }
        
        @http = sinon.stub()
        @http.returns { header: @postHeadersStub }
        
        client = new Client { http: @http }
        
        promise = client.createUser 'U83746', 'andrewseward' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should create the http client for the users URL with the expected authentication', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/users", sinon.match({ auth: "#{@user}:#{@pass}" }))
          
      it 'should create the user', ->
          expect(@postHeadersStub).to.have.been.calledWith('Content-Type', 'application/json')
          expect(@postStub).to.have.been.calledWith('{"userid":"U83746","name":"andrewseward"}')

      it 'should resolve with status code 201', ->
          expect(@result).to.equal(201)

    describe 'when user exists', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'https://api.hack24.deadpool'
        
        process.env.HACKBOT_USERNAME = 'some adasdasd'
        process.env.HACKBOT_PASSWORD = 'a dfdgdgd'
        
        postExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 409 }, null)
        postStub = sinon.stub().returns postExecStub 
        
        postHeadersStub = sinon.stub().returns { post: postStub }
        
        http = sinon.stub()
        http.returns { header: postHeadersStub }
        
        client = new Client { http: http }
        
        promise = client.createUser 'U10101', 'bananapete' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should resolve with status code 409', ->
          expect(@result).to.equal(409)

    describe 'when http error', ->
    
      before (done) ->
        process.env.HACK24API_URL = 'https://coffeescript.is.cool'
        
        process.env.HACKBOT_USERNAME = 'some adasdasd'
        process.env.HACKBOT_PASSWORD = 'a dfdgdgd'
        
        @httpError = new Error('an error')
        
        postExecStub = sinon.stub().callsArgWith(0, @httpError, null, null)
        postStub = sinon.stub().returns postExecStub 
        
        postHeadersStub = sinon.stub().returns { post: postStub }
        
        http = sinon.stub()
        http.returns { header: postHeadersStub }
        
        client = new Client { http: http }
        
        promise = client.createUser 'Some Guy', 'Some Name'
        promise.then -> done()
        promise.catch (err) =>
          @err = err
          done()

      it 'should reject with the error', ->
          expect(@err).to.equal(@httpError)


  describe '#removeTeamMember', ->
    
      before (done) ->
        @apiUrl = process.env.HACK24API_URL = 'flying.over.cities.down.to.rio'
        
        @user = process.env.HACKBOT_USERNAME = 'net'
        @pass = process.env.HACKBOT_PASSWORD = 'sky'
        
        teamResponse = JSON.stringify
          members: [ 'Johnny', 'Becky' ]
        
        postExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 201 }, null)
        @postStub = sinon.stub().returns postExecStub
        
        getExecStub = sinon.stub().callsArgWith(0, null, { statusCode: 200 }, null)
        @getStub = sinon.stub().returns getExecStub
        
        @headersStub = sinon.stub()
        @headersStub.withArgs("#{@apiUrl}/teams/#{teamId}", sinon.match({ auth: "#{@user}:#{@pass}" })).returns { post: @postStub }
        @headersStub.withArgs("#{@apiUrl}/teams/#{teamId}").returns { get: @getStub }
        
        @http = sinon.stub()
        @http.returns { header: @headersStub }
        
        client = new Client { http: @http }
        
        @teamId = 'swan-song'
        
        promise = client.removeTeamMember @teamId, 'U12345' 
        promise.then (result) =>
          @result = result
          done()
        promise.catch done

      it 'should create the http client for the team URL with the expected authentication', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/teams/#{teamId}", )

      it 'should create the http client for the team URL with the expected authentication', ->
          expect(@http).to.have.been.calledWith("#{@apiUrl}/teams/#{teamId}", sinon.match({ auth: "#{@user}:#{@pass}" }))
          
      it 'should update the team with this user as the only member', ->
          expect(@headersStub).to.have.been.calledWith('Content-Type', 'application/json')
          expect(@postStub).to.have.been.calledWith('{"name":"Pineapple Express","members":["U12345"]}')

      it 'should resolve with status code 201', ->
          expect(@result).to.equal(201)