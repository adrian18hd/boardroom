{ Identity, Factory } = require '../support/model_test_support'

describe 'Identity', ->
  it 'exists', ->
    expect(Identity).toBeDefined()

  describe 'generateHash', ->
    identity = undefined
    password = 'safe-password'

    beforeEach (done) ->
      Factory.create 'identity', (error, created_identity) ->
        identity = created_identity
        identity.password = identity.generateHash(password)
        identity.save
        done()

    it 'generates a valid hashed password', ->
      expect(identity.validPassword(password)).toEqual(true)
