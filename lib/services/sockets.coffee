sockets = require 'socket.io'
logger = require './logger'
Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class Sockets
  @users: {}

  @boardsNamespace: () ->
    env = process.env.NODE_ENV ? 'development'
    "/#{env}/boards"

  @createSocket: (io) ->
    handlers =
      board: Board
      group: Group
      card : Card

    namespace = @boardsNamespace()

    io
      .of(namespace)
      .on 'connection', (socket) =>
        remoteAddress = socket.handshake.headers['x-forwarded-for'] || socket.handshake.address.address
        logger.debug -> "Socket connection from #{remoteAddress} (pid #{process.pid})"

        socket.on 'disconnect', =>
          delete @users[socket.boardroomUser?.id]
          logger.info -> "#{socket.boardroomUser?.displayName} has disconnected"

        socket.on 'join', (message) =>
          { user, boardId } = message
          new Handler(modelClass, name, boardId, socket).registerAll() for name, modelClass of handlers

          socket.join boardId
          @users[user.userId] = user
          socket.boardroomUser = user
          socket.broadcast.to(boardId).emit 'join', { userId: user.userId, @users }
          logger.info -> "#{user.displayName} has joined board #{boardId} (pid: #{process.pid})"

        socket.on 'log', ({user, boardId, level, msg}) =>
          logger.logClient user, boardId, level, msg

        socket.on 'marker', ({user, boardId}) =>
          logger.rememberEvent boardId, 'marker', { author: user }

  @start: (server) ->
    RedisStore = require 'socket.io/lib/stores/redis'
    redis      = require 'socket.io/node_modules/redis'

    store = new RedisStore
      redisPub: redis.createClient()
      redisSub: redis.createClient()
      redisClient: redis.createClient()

    io = sockets.listen server
    io.set 'log level', 1
    io.set 'store', store

    @createSocket io

module.exports = Sockets
