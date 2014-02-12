logger = require '../services/logger'
ApplicationController = require './application'
BoardsController = require '../controllers/boards'
User = require '../models/user'
Board = require '../models/board'
async = require 'async'
path = require 'path'
fs = require 'fs'
passport = require 'passport'

passport.serializeUser (user, done)-> done null, user._id
passport.deserializeUser (_id, done)-> User.findOne { _id }, done

class SessionsController extends ApplicationController

  constructor: ()->
    @authenticators = {}
    @registerAuthenticators()

  registerAuthenticators: ()=>
    providers = fs.readdirSync path.resolve __dirname, '../services/authentication/providers/'
    for filename in providers
      do (filename)=>
        providerAuthenticator = require "../services/authentication/providers/#{filename}"
        if providerAuthenticator.oauth
          if providerAuthenticator.isConfigured()
            try
              passport.use providerAuthenticator.passportStrategy()
              @authenticators[providerAuthenticator.name] = providerAuthenticator
              logger.debug -> "auth: registered #{providerAuthenticator.name} provider"
            catch e
              logger.warn -> "auth: error regsitering #{providerAuthenticator.name} provider - #{e.message}"
          else
            logger.warn -> "auth: unable to register #{providerAuthenticator.name} provider - not configured"
        else
          passport.use providerAuthenticator.name, providerAuthenticator.passportStrategy()
          @authenticators[providerAuthenticator.name] = providerAuthenticator

  newOAuth: (request,response, next)=>
    provider = request.params?.provider
    authenticator = @authenticators[provider]
    unless authenticator?
      logger.error -> "no registered provider for #{provider}"
      response.redirect '/login'
      return

    try
      opts = authenticator.authenticationOptions()
      passport.authenticate(provider, opts)(request,response)
    catch e
      logger.error -> "error authenticating with #{provider} - #{e.message}"
      response.redirect '/login'

  createOAuth: (request,response, next)=>
    provider = request.params?.provider
    failureRedirect = '/login'
    successRedirect = '/'
    if request.session?.got2URL?
      successRedirect = request.session?.got2URL
      delete request.session.got2URL
    passport.authenticate(provider, { successRedirect, failureRedirect })(request,response, next)

  new: (request, response) =>
    providers = for name, provider of @authenticators
      name
    response.render 'login', {layout: false, providers}

  create: (request, response, next) =>
    failureRedirect = '/failed'
    successRedirect = '/success'
    passport.authenticate('local-login', { successRedirect, failureRedirect })(request, response, next)

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController
