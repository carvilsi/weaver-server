# Script to modify the password of users from plain text to hashed

bcrypt = require('bcrypt')
fs = require('fs')
Promise = require('bluebird')
loki = require('lokijs')
conf = require('config')

folder = 'loki'
file = 'users'

createHashes = (user, users) ->
  bcrypt.hash(user.password, conf.get('auth.salt'))
  .then((hash) =>
    user.password = hash
    users.update(user)
  ).catch((err) ->
    console.log "Something went wrong :S"
    console.error err
  )

loaded = ->
  promises = []
  users = db.getCollection('users')
  results = users.find()
  for user in results
    promises.push(createHashes(user, users))
  Promise.all(promises)
  .then( =>
    db.saveDatabase()
    console.log "Done! No more plain text passwords :)"
  )
  
db = new loki("#{folder}/#{file}.json",
autoload: true
autoloadCallback: loaded)
