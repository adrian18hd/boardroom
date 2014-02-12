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
    new @passportStrategyClass { usernameField: 'username', passReqToCallback: true }, @passportCallback

  passportCallback: (request, username, password, done) =>
    process.nextTick ->
      Identity.findOne { 'username' :  username }, (err, identity) ->
        if (err)
          return done(err)

        if (!identity)
          return done(null, false)

        if (!identity.validPassword(password))
          return done(null, false)

        User.logIn identity, done

module.exports = new LocalLogin
