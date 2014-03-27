express = require 'express'
http = require 'http'

Sockets = require './services/sockets'

configure = require './config'
addRouting = require './routes'

class Boardroom
  constructor: (@opts = {}) ->
    @env = @opts.env ? 'development'
    @port = @opts.port ? 7777
    loginProtection = @opts.loginProtection ? require './services/authentication/login_protection'
    createSocketNamespace = @opts.createSocketNamespace ? Sockets.middleware

    @app = express()
    configure @app
    addRouting @env, @app, loginProtection, createSocketNamespace

  start: ->
    server = http.createServer @app
    Sockets.start server
    server.listen @port

module.exports = Boardroom
