{ Session, Factory, url, async, describeController, superagent } =
  require '../support/controller_test_support'

SessionsController = require '../../../lib/controllers/sessions'

sinon = require 'sinon'

describeController 'SessionsController', (session) ->
  describe '#createLocal', ->
    response = undefined

    describe 'the users logs in with local credentials', ->
      beforeEach (done) ->
        username = 'my-special-name'
        password = 'safe-password'

        Factory.create 'identity', {username: username }, (error, identity) ->
          identity.password = identity.generateHash(password)
          identity.save (err)->
            throw err if err
            session.request()
              .post('/login')
              .send({ username: username, password: password })
              .end (req, res)->
                response = res
                done()

      it 'logs the user into the success page', ->
        expect(response).toBeDefined()
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/'

    describe 'the users logs in with incorrect credentials', ->
      beforeEach (done) ->
        session.request()
          .post('/login')
          .send({ username: 'not-real', password: 'incorrect' })
          .end (req, res)->
            response = res
            done()

      it 'keeps them on the login page', ->
        expect(response).toBeDefined()
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/login'
