DB = require './helper'

exports.up = (next) ->
  DB.ensureIndex 'cards', { boardName: 1 }, (error, result) ->
    DB.find 'boards', {}, (error, boards) ->
      return next error if error?
      return next() if boards.length == 0
      count = 0
      for board in boards
        do (board) ->
          update =
            $set:
              boardId: board._id.toHexString()
            $unset:
              boardName: 1
          DB.update 'cards', { boardName: board.name }, update, (error, num) ->
            return next error if error?
            console.log "  Updated #{num} cards in board #{board.name}" if num > 0
            count += 1
            next() if count == boards.length
