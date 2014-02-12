{ Identity, Factory, url, async, describeController, superagent } =
  require '../support/controller_test_support'

IdentitiesController = require '../../../lib/controllers/identities'

describeController 'IdentitiesController', (session) ->
  describe '#create', ->
    username = 'my-great-username'
    password = 'my-secure-password'

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
