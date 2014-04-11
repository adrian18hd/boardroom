fs = require 'fs'
_s = require 'underscore.string'
helper = require '../../migrations/helper'
logger = require './logger'

class Migrator
  constructor: ->
    @migrations = @loadMigrations()

  migrate: (callback) ->
    next = (error) =>
      return callback error if error?
      if @migrations.length == 0
        helper.disconnect()
        return callback()

      migration = @migrations.shift()
      start = Date.now()
      m = require migration
      m.up () ->
        finish = Date.now()
        ms = _s.sprintf "%4d", (finish - start)
        logger.info -> "migrate: #{ms}ms  #{migration.split('/').pop()}"
        next()

    helper.connect (error) ->
      next error

  loadMigrations: ->
    fs.readdirSync("#{@migrationsDir()}").filter (file) ->
      file.match(new RegExp('^\\d+.*\\.(js|coffee)$'))
    .sort().map (file) =>
      "#{@migrationsDir()}/#{file}"

  migrationsDir: ->
    "#{__dirname}/../../migrations"

module.exports = Migrator
