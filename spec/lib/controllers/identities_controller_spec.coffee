{ Identity, Factory, url, async, describeController, superagent } =
  require '../support/controller_test_support'

IdentitiesController = require '../../../lib/controllers/identities'

describeController 'IdentitiesController', (session) ->
  describe '#create', ->
    response = undefined
    username = 'my-great-username'
    password = 'my-secure-password'

    describe 'when the identity is new', ->
      beforeEach (done) ->
        session.request()
          .post('/signup')
          .send({ username: username, password: password })
          .end (req, res)->
            response = res
            done()


      it 'creates a new Identity', (done) ->
        Identity.count {username: username}, (err, count) ->
          expect(count).toEqual 1
          done()

      it 'redirects to created', ->
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/created'

    describe 'when the identity already exists', ->
      beforeEach (done) ->
        Identity.create {username: username}, (err, identity) ->
          identity.password = identity.generateHash(password)
          identity.save (err) ->
            throw err if err

        session.request()
          .post('/signup')
          .send({ username: username, password: password })
          .end (req, res)->
            response = res
            done()

      it 'does not create a new Identity', (done) ->
        Identity.count {username: username}, (err, count) ->
          expect(count).toEqual 1
          done()
