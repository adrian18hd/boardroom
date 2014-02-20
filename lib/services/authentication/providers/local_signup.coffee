LocalStrategy = require('passport-local').Strategy

mailer = require '../../mailer'
crypto = require 'crypto'
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

          md5 = crypto.createHash 'md5'
          md5.update email
          newIdentity.avatar = "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"

          confirmationCode = crypto.createHash 'md5'
          confirmationCode.update newIdentity.displayName
          newIdentity.confirmationCode = confirmationCode.digest('hex')

          newIdentity.save (err) ->
            throw err if err

            confirmationLink = "http://#{request.get('host')}/identities/confirm/#{newIdentity.confirmationCode}"

            emailOptions = {
              to: email,
              subject: 'Confirm your Boardroom account',
              body: "Click this link to confirm your Boardroom account: #{confirmationLink}"
            }

            mailer.send(emailOptions)
            return done(null, newIdentity)

module.exports = new LocalSignup
