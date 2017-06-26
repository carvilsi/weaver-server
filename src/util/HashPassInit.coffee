bcrypt  = require('bcrypt')
fs      = require('fs')
Promise = require('bluebird')
loki    = require('lokijs')
conf    = require('config')
logger  = require('logger')

class HashPassInit

  folder = 'loki'
  file = 'users'
  db = null

  constructor: ()->
    db = new loki("#{folder}/#{file}.json",
    autoload: true
    autoloadCallback: loaded)

  createHashes = (user, users) ->
    bcrypt.hash(user.password, conf.get('auth.salt'))
    .then((hash) =>
      delete user.password
      user.passwordHash = hash
      users.update(user)
    ).catch((err) ->
      logger.config.error("Something went wrong trying to hashing the passwords in plain text :S")
    )

  loaded = ->
    promises = []
    users = db.getCollection('users')

    return Promise.resolve() if !users?

    results = users.find()
    for user in results
      if user.password?
        logger.config.warn("Some password on plain text has been founded for user #{user.username}. Trying to fix it applaying hashes")
        promises.push(createHashes(user, users))
    if promises.length > 0
      Promise.all(promises)
      .then( =>
        db.saveDatabase()
        logger.config.warn('Done! No more plain text passwords :)')
      )

  module.exports = HashPassInit
