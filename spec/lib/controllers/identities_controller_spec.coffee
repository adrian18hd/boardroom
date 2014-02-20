{ Identity, Factory, url, async, describeController, superagent } =
  require '../support/controller_test_support'

mailer = require '../../../lib/services/mailer'
IdentitiesController = require '../../../lib/controllers/identities'

describeController 'IdentitiesController', (session) ->
  describe '#create', ->
    response = undefined
    email = 'my-great-username@gmail.com'
    password = 'my-secure-password'
    name = 'My Name'

    describe 'when the identity is new', ->
      confirmationLink = 'http://blah.com/identities/confirm/12345'
      emailParams = {
        to: email,
        subject: 'Confirm your Boardroom account',
      }
      emailBodyRegex = /^Click this link to confirm your Boardroom account: http:\/\/.*/

      beforeEach (done) ->
        spyOn(mailer, 'send')

        session.request()
          .post('/signup')
          .send({ email: email, password: password, displayName: name })
          .end (req, res)->
            response = res
            done()

      it 'creates a new Identity', (done) ->
        Identity.count {email: email}, (err, count) ->
          expect(count).toEqual 1
          done()

      it 'redirects to boards list page', ->
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/'

      it 'requests an email be sent', ->
        mailerOptions = mailer.send.mostRecentCall.args[0]
        expect(mailerOptions.to).toEqual(emailParams.to)
        expect(mailerOptions.subject).toEqual(emailParams.subject)
        expect(mailerOptions.body).toMatch(emailBodyRegex)

    describe 'when the identity already exists', ->
      beforeEach (done) ->
        Identity.create {email: email}, (err, identity) ->
          identity.password = identity.generateHash(password)
          identity.save (err) ->
            throw err if err

        session.request()
          .post('/signup')
          .send({ email: email, password: password })
          .end (req, res)->
            response = res
            done()

      it 'does not create a new Identity', (done) ->
        Identity.count {email: email}, (err, count) ->
          expect(count).toEqual 1
          done()

  describe '#confirm', ->
    response = undefined
    email = 'my-special-email@gooble.com'
    confirmationCode = '123456789'

    describe 'when the identity is unconfirmed', ->
      beforeEach (done) ->
        Identity.create {email: email, confirmationCode: confirmationCode }, (err, identity) ->
          session.request()
            .get("/identities/confirm/#{confirmationCode}")
            .end (req, res)->
              response = res
              done()

      it 'confirms the Identity', (done) ->
        Identity.findOne {email: email}, (err, identity) ->
          expect(identity.confirmationCode).toBeNull()
          done()

      it 'redirects to login', ->
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/login'

    describe 'when the identity is confirmed', ->
      beforeEach (done) ->
        Identity.create {email: email, confirmationCode: null }, (err, identity) ->
          session.request()
            .get("/identities/confirm/#{confirmationCode}")
            .end (req, res)->
              response = res
              done()

      it 'redirects to login', ->
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/login'
