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
    failureRedirect = '/signup'
    successRedirect = '/'
    passport.authenticate('local-signup', { successRedirect, failureRedirect })(request, response, next)

  confirm: (request, response, next) =>
    Identity.findOne { 'confirmationCode': request.params.confirmationCode }, (err, identity) =>
      if identity
        identity.confirmationCode = null
        identity.save (err) ->
          throw err if err
          response.redirect '/login'
      else
        response.redirect '/login'


module.exports = IdentitiesController
