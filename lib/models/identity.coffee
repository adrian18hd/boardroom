{ mongoose } = require './db'
passwordHash = require 'password-hash'

identitySchema = new mongoose.Schema
  source: String
  sourceId: String
  username: String
  displayName: String
  avatar: String
  email: String
  password: String
  confirmationCode: String

identitySchema.methods.generateHash = (password) ->
  return passwordHash.generate(password)

identitySchema.methods.validPassword = (password) ->
  return passwordHash.verify(password, @password)

Identity = mongoose.model 'Identity', identitySchema

module.exports = Identity
