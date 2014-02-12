local_login = require '../../../../../lib/services/authentication/providers/local_login'

describe 'local_login', ->
  it 'exists', ->
    expect(local_login).toExist

  it 'has local as its name', ->
    expect(local_login.name).toEqual 'local-login'
