local = require '../../../../../lib/services/authentication/providers/local'

describe 'local', ->
  it 'exists', ->
    expect(local).toExist

  it 'has local as its name', ->
    expect(local.name).toEqual 'local'
