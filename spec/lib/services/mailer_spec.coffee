{ describeController } =
  require '../support/controller_test_support'

mailer = require '../../../lib/services/mailer'

describeController 'Mailer', (session) ->
  defaultParams = {
    from: 'noreply@stickies.io'
  }

  describe '.new', ->
    it 'sets default options', ->
      expect(mailer.defaultMailOptions).toEqual defaultParams

    it 'creates a transport', ->
      expect(mailer.smtpTransport).toBeDefined()

  describe '#send', ->
    toEmail = 'user@userdomain.com'
    emailSubject = 'Email Subject'
    emailBody = 'Email body...'

    passedParams = {
      to: toEmail,
      subject: emailSubject,
      body: emailBody
    }

    fullEmailParams = {
      from: 'noreply@stickies.io',
      to: toEmail,
      subject: emailSubject,
      body: emailBody
    }

    beforeEach ->
      spyOn(mailer.smtpTransport, 'sendMail')
      mailer.send(passedParams)

    it 'calls sendMail with the correct options', ->
      expect(mailer.smtpTransport.sendMail.mostRecentCall.args[0]).toEqual(fullEmailParams)
