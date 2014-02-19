logger = require './logger'
_ = require 'underscore'
nodemailer = require 'nodemailer'

class Mailer
  constructor: ->
    @smtpTransport = nodemailer.createTransport "SMTP",
      service: "Sendmail"

    @defaultMailOptions =
      from: 'noreply@stickies.io',

  send: (options) ->
    mailOptions = _.extend(@defaultMailOptions, options)
    @smtpTransport.sendMail mailOptions, (error, response) ->
      if error
        logger.info -> error
      else
        logger.info -> 'Mail sent!'

module.exports = new Mailer()
