LocalStrategy = require('passport-local').Strategy

Provider = require '../provider'
Identity = require '../../../models/identity'

class LocalSignup extends Provider
  oauth: false
  name: 'local-signup'

  passportStrategyClass: LocalStrategy

  isConfigured: => true

  passportStrategy: =>
    new @passportStrategyClass { usernameField: 'email', passReqToCallback: true }, @passportCallback

  passportCallback: (request, email, password, done) =>
    process.nextTick ->
      Identity.findOne { 'email': email }, (err, identity) ->
        if err
          return done(err)
        else if identity
          return done(null, false)
        else
          newIdentity = new Identity()
          newIdentity.email = email
          newIdentity.password = newIdentity.generateHash(password)
          newIdentity.displayName = request.body.displayName ? email

          newIdentity.save (err) ->
            throw err if err
            return done(null, newIdentity)

module.exports = new LocalSignup
