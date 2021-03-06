Factory = require 'factory-lady'
_ = require 'underscore'
async = require "async"

Board = require "#{__dirname}/../../../lib/models/board"
Group = require "#{__dirname}/../../../lib/models/group"
Card = require "#{__dirname}/../../../lib/models/card"
User = require "#{__dirname}/../../../lib/models/user"
Identity = require "#{__dirname}/../../../lib/models/identity"

Factory.define 'user', User,
  identities: (cb)->
    Factory.create 'identity', (error, identity) ->
      cb [identity]

identityCounter = 0

Factory.define 'identity', Identity,
  displayName: (cb)-> cb "my-username-#{++identityCounter}" 
  source: (cb)-> cb "source-#{identityCounter}" 
  sourceId: (cb)-> cb "sourceId-#{identityCounter}" 
  avatar: (cb)-> cb "http://my-avatar-#{identityCounter}.png" 
  email: (cb)-> cb "my-email-#{identityCounter}@here.com" 

boardCounter = 0
Factory.define 'board', Board,
  name: (cb) -> cb "board-#{boardCounter++}"
  creator: Factory.assoc 'user', 'id'

groupCounter = 0
Factory.define 'group', Group,
  boardId: Factory.assoc 'user', 'id'
  boardId: (cb) ->
    Factory.create 'board', (error, board) ->
      cb board.id
  name: (cb) -> cb "group-#{groupCounter++}"
  x: 100
  y: 100
  z: 1

Factory.define 'card', Card,
  groupId: Factory.assoc 'group', 'id'
  creator: Factory.assoc 'user', 'id'
  text: 'text'
  colorIndex: 2
  deleted: false
  authors: (cb) ->
    Factory.create 'user', (error, user) ->
      cb [user]
  plusAuthors: (cb) ->
    Factory.create 'user', (error, user) ->
      cb [user]

Factory.createBundle = (callback) ->
  async.parallel {
    boardCreator1: async.apply Factory.create, 'user'
    boardCreator2: async.apply Factory.create, 'user'
    boardCreator3: async.apply Factory.create, 'user'
    boardCreator4: async.apply Factory.create, 'user'
    someotherguy: async.apply Factory.create, 'user'
    nobody: async.apply Factory.create, 'user'
  }, (error, users) ->
    if error?
      callback(error, null)
    else

      authors = [
        [users.boardCreator1]
        [users.boardCreator1, users.someotherguy]
        [users.boardCreator1]
        [users.nobody]
      ]

      calls = []

      for i in [1..4]
        do (i) ->
          calls.push (done) ->
            Factory 'board', name: "board#{i}", creator: users["boardCreator#{i}"], (err, board) ->
              Factory 'group', boardId: board.id, (err, group) ->
                Factory 'card', groupId: group.id, authors: authors[i-1], (err, card) ->
                  done err, board

      async.parallel calls, (error, boards) ->
        callback error, { boards, users }

module.exports = Factory
