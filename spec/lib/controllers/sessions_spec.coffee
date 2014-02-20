{ Session, Factory, url, async, describeController, superagent } =
  require '../support/controller_test_support'

SessionsController = require '../../../lib/controllers/sessions'

sinon = require 'sinon'

describeController 'SessionsController', (session) ->
  describe '#createLocal', ->
    response = undefined

    describe 'the users has a local account', ->
      email = 'my-special-name@gmail.com'
      password = 'safe-password'

      describe 'the account is confirmed', ->
        beforeEach (done) ->
          Factory.create 'identity', {email: email}, (error, identity) ->
            identity.password = identity.generateHash(password)
            identity.save (err)->
              throw err if err
              session.request()
                .post('/login')
                .send({ email: email, password: password })
                .end (req, res)->
                  response = res
                  done()

        it 'logs the user into the boards page', ->
          expect(response).toBeDefined()
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'

      describe 'the account is not confirmed', ->
        beforeEach (done) ->
          Factory.create 'identity', {email: email, confirmationCode: '12345'}, (error, identity) ->
            identity.password = identity.generateHash(password)
            identity.save (err)->
              throw err if err
              session.request()
                .post('/login')
                .send({ email: email, password: password })
                .end (req, res)->
                  response = res
                  done()

        it 'returns the user to the login page', ->
          expect(response).toBeDefined()
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/login'

    describe 'the users does not have a local account', ->
      beforeEach (done) ->
        session.request()
          .post('/login')
          .send({ email: 'not-real', password: 'incorrect' })
          .end (req, res)->
            response = res
            done()

      it 'keeps them on the login page', ->
        expect(response).toBeDefined()
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/login'
