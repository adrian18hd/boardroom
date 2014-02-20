LocalStrategy = require('passport-local').Strategy

Provider = require '../provider'
Identity = require '../../../models/identity'
User = require '../../../models/user'

class LocalLogin extends Provider
  oauth: false
  name: 'local-login'

  passportStrategyClass: LocalStrategy

  isConfigured: => true

  passportStrategy: =>
    new @passportStrategyClass { usernameField: 'email', passReqToCallback: true }, @passportCallback

  passportCallback: (request, email, password, done) =>
    process.nextTick ->
      Identity.findOne { 'email' :  email }, (err, identity) ->
        if (err)
          return done(err)

        if (!identity)
          return done(null, false)

        if (identity.confirmationCode)
          return done(null, false)

        if (!identity.validPassword(password))
          return done(null, false)

        User.logIn identity, false, done

module.exports = new LocalLogin
