LocalStrategy = require('passport-local').Strategy

Provider = require '../provider'
Identity = require '../../../models/identity'

class LocalSignup extends Provider
  oauth: false
  name: 'local-signup'

  passportStrategyClass: LocalStrategy

  isConfigured: => true

  passportStrategy: =>
    new @passportStrategyClass { usernameField: 'username', passReqToCallback: true }, @passportCallback

  passportCallback: (request, username, password, done) =>
    process.nextTick ->
      Identity.findOne { 'username' :  username }, (err, identity) ->
        if err
          return done(err)
        else if identity
          return done(null, false)
        else
          newIdentity = new Identity()
          newIdentity.username = username
          newIdentity.password = newIdentity.generateHash(password)

          newIdentity.save (err) ->
            throw err if err
            return done(null, newIdentity)

module.exports = new LocalSignup
