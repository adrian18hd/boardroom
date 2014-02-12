logger = require '../services/logger'
ApplicationController = require './application'
Identity = require '../models/identity'
passport = require 'passport'

class IdentitiesController extends ApplicationController
  create: (request, response, next) =>
    identity = new Identity { username: request.body.username }
    identity.password = identity.generateHash(request.body.password)
    identity.save (err) ->
      throw err if err
      next()

module.exports = IdentitiesController
