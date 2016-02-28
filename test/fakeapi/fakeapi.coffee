express = require 'express'
bodyParser = require 'body-parser'

class FakeEndpoint
  constructor: (@method, @route) ->
    @headerFilters = {}

  @delete: (route) ->
    builder = new FakeEndpoint 'delete', route
    builder
  
  matchesHeader: (header, value) ->
    @headerFilters[header] = value
    @
  
  respond: (@body) ->
    @
  
  status: (@status) ->
    @

class FakeApi

  constructor: (@port) ->
    @api = express()
    @endpoints = []
    
    jsonParser = bodyParser.json()
    
    @api.use jsonParser, (req, res, next) =>
      console.log(req.path)
      # @endpoints.find (endpoint) ->
      res.status(500).send('No endpoint')
        
  
  start: ->
    new Promise (resolve, reject) =>
      @server = @api.listen @port, (err) ->
        if err? then return reject(err)
        resolve() 
  
  stop: ->
    new Promise (resolve, reject) =>
      @server.close ->
        resolve()

  addEndpoint: (endpoint) ->
    @endpoints.push[endpoint]

module.exports.FakeApi = FakeApi
module.exports.FakeEndpoint = FakeEndpoint