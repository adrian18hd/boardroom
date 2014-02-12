logger = require '../services/logger'
ApplicationController = require './application'
Identity = require '../models/identity'
localSignup = require '../services/authentication/providers/local_signup'
passport = require 'passport'

class IdentitiesController extends ApplicationController
  constructor: ()->
    passport.use localSignup.name, localSignup.passportStrategy()

  new: (request, response, next) =>
    response.render 'signup', {layout: false}

  create: (request, response, next) =>
    failureRedirect = '/failed'
    successRedirect = '/created'
    passport.authenticate('local-signup', { successRedirect, failureRedirect })(request, response, next)

module.exports = IdentitiesController
