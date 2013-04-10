express = require 'express'

Sockets = require './services/sockets'

configure = require './config'
addRouting = require './routes'

class Boardroom
  constructor: (@opts = {}) ->
    @opts.cluster ?= false
    authenticate = @opts.authenticate ? require './services/authenticate'
    createSocketNamespace = @opts.createSocketNamespace ? Sockets.middleware

    @app = express()
    configure @app
    addRouting @app, authenticate, createSocketNamespace

  start: ->
    server = @app.listen parseInt(process.env.PORT) || 7777
    Sockets.start server, @opts

module.exports = Boardroom
