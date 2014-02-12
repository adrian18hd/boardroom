local_signup = require '../../../../../lib/services/authentication/providers/local_signup'

describe 'local_signup', ->
  it 'exists', ->
    expect(local_signup).toExist

  it 'has local as its name', ->
    expect(local_signup.name).toEqual 'local-signup'
