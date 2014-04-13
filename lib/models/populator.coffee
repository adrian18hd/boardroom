User = require './user'
Board = require './board'
Group = require './group'
Card  = require './card'
async = require 'async'
_ = require 'underscore'
class Populator
  constructor: () ->

  populate: (callback, cardinality="*") ->
    return undefined unless callback?
    (error, boardCursor) =>
      if 1 is cardinality
        @populateOne callback, boardCursor
      else
        @populateMany callback, boardCursor

  populateMany: (callback, boards) ->
    return (callback null, []) unless boards? and 0 isnt boards?.length
    count = 0
    @findGroupsAndCards boards, (gmap, cmap) =>
      for board in boards
        @fillBoard board, gmap, cmap, (error, board) ->
          return callback error if error?
          count += 1
          callback null, boards if count == boards.length

  populateOne: (callback, board) ->
    return callback null, null unless board?
    @findGroupsAndCards [board], (gmap, cmap) =>
      @fillBoard board, gmap, cmap, (error, board) ->
        return callback error if error?
        callback null, board

  findGroupsAndCards: (boards, callback) ->
    boardIds = _(boards).pluck '_id'
    Group.find { boardId: { $in: boardIds } }, (error, groups) =>
      return callback error if error?
      groupIds = _(groups).pluck '_id'
      gmap = _(groups).groupBy 'boardId'
      Card.find { groupId: { $in: groupIds } }, (error, cards) =>
        return callback error if error?
        cmap = _(cards).groupBy 'groupId'
        callback gmap, cmap

  fillBoard: (board, gmap, cmap, callback) ->
    groups = gmap[board._id]
    board.groups = []
    return callback null, board unless groups?
    count = 0
    for group in groups
      @fillGroup group, cmap, (error, group) =>
        return callback error if error?
        board.groups.push group
        count += 1
        if count == groups.length
          @fillUsers board, callback

  fillUsers: (board, callback) ->
    userIds = [board.creator]
    ( userIds = userIds.concat [card.creator, card.authors..., card.plusAuthors...] ) for card in board.cards()
    userIds = _(userIds).uniq()

    User.find { _id: { $in: userIds } }, (error, users) =>
      return callback error if error?
      identSet = _.object( _(users).map (u) -> [u._id, u.activeIdentity] )
      board.userIdentitySet = identSet ? {}
      callback null, board

  fillGroup: (group, cmap, callback) ->
    cards = cmap[group._id]
    group.cards = cards
    callback null, group

module.exports = Populator
