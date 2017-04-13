config     = require('config')
mysql      = require('mysql-promise')
Promise    = require('bluebird')
logger     = require('logger')

class Tracker

  constructor: (tracker) ->
    @tries = 10
    @delay = 5000
    @db = mysql()
    @dbName = tracker.database
    @db.configure({
      host     : tracker.host
      port     : tracker.port
      user     : tracker.user
      password : tracker.password
      dateStrings: true # force dates as string, no javascript date
    })


  checkInitialized: ->
    console.log db
    logger.code.debug("Trying to connect to trackerdb on #{'services.tracker.host'}")
    delay = 5000
    @db.query('USE `'+@dbName+'`;').then(=>
      @db.query('SELECT * FROM `tracker` LIMIT 1;')
    ).then(=>
      true
    ).catch((error)=>
      if error.code in [ 'ER_BAD_DB_ERROR', 'ER_NO_SUCH_TABLE' ]
        false
      else
        if @tries-- > 0
          Promise.delay(@delay).then(=>@checkInitialized())
        else
          Promise.reject("Tracker could not connect to mysql database, #{error.code}. Tried with #{'services.tracker.user'}@#{'services.tracker.host'}:#{'services.tracker.port'} with pass #{'services.tracker.password'}")
    )


  initDb: ->
    @checkInitialized().then((done)=>
      return Promise.resolve() if done
      @db.query('CREATE DATABASE IF NOT EXISTS `'+@dbName+'`;')
      .then(=>
        @db.query('USE `'+@dbName+'`;')
      ).then(=>
        @db.query('DROP TABLE IF EXISTS `tracker`;')
      ).then(=>
        @db.query('
          CREATE TABLE `tracker` (
          `seqnr` BIGINT NOT NULL AUTO_INCREMENT,
          `timestamp` BIGINT  NOT NULL,
          `datetime` datetime  NOT NULL,
          `user` varchar(128) NOT NULL,
          `action` varchar(128) NOT NULL,
          `node` varchar(128) NOT NULL,
          `key` varchar(128) NULL,
          `to` varchar(128) NULL,
          `oldTo` varchar(128) NULL,
          `value` text NULL,
          `payload` text NOT NULL,
          PRIMARY KEY (`seqnr`),
          INDEX `timestamp_index` (`timestamp` ASC),
          INDEX `user_index` (`user` ASC),
          INDEX `action_index` (`action` ASC),
          INDEX `node_index` (`node` ASC),
          INDEX `key_index` (`key` ASC),
          INDEX `to_index` (`to` ASC)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
        )
      )
    )




  processWrites: (writes, user, project)->

    if not writes? or writes.length < 1
      return Promise.resolve()

    query = 'INSERT INTO `trackerdb`.`tracker` (`timestamp`, `datetime`, `user`, `action`, `node`, `key`, `to`, `oldTo`, `value`, `payload`) VALUES '
    quote = '\''

    for operation in writes

      timestamp = operation.timestamp
      datetime = Math.round(operation.timestamp / 1000)
      user_id = quote + user.id + quote
      action = quote + operation.action + quote

      node_id = 'NULL'
      key = 'NULL'
      to = 'NULL'
      oldTo = 'NULL'
      value = 'NULL'

      if operation.id?
        node_id = quote + operation.id + quote
      else if operation.from?
        node_id = quote + operation.from + quote
      if operation.key?
        key = quote + operation.key + quote
      if operation.to?
        to = quote + operation.to + quote
      if operation.newTo?
        to = quote + operation.newTo + quote
      if operation.oldTo?
        oldTo = quote + operation.oldTo + quote
      if operation.value?
        value = @db.pool.escape(operation.value)

      payload = @db.pool.escape(JSON.stringify(operation))

      query += "(#{timestamp}, FROM_UNIXTIME(#{datetime}), #{user_id}, #{action}, #{node_id}, #{key}, #{to}, #{oldTo}, #{value}, #{payload}),"

    query = query.slice(0, -1)+';'

    @db.query(query)



  getHistoryFor: (req)->

    quote = '\''
    conditions = []
    query = 'SELECT `seqnr`, `datetime`, `user`, `action`, `node`, `key`, `to`, `value` FROM `trackerdb`.`tracker`'

    if req.payload.users?
      conditions.push('`user` IN (' + quote + req.payload.users.join(quote + ', ' + quote) + quote + ')')

    if req.payload.ids?
      conditions.push('`node` IN (' + quote + req.payload.ids.join(quote + ', ' + quote) + quote + ')')

    if req.payload.keys?
      conditions.push('`key` IN (' + quote + req.payload.keys.join(quote + ', ' + quote) + quote + ')')

    if req.payload.fromDateTime?
      conditions.push('`datetime` >= ' + quote + req.payload.fromDateTime + quote)

    if req.payload.beforeDateTime?
      conditions.push('`datetime` < ' + quote + req.payload.beforeDateTime + quote)

    if conditions.length > 0
      query = query.concat(' WHERE ' + conditions.join(' AND '))

    query = query.concat(' ORDER BY `seqnr` ASC')

    if req.payload.limit?
      query = query.concat(" limit #{req.payload.limit}")

    query = query.concat(';')

    logger.code.debug("The query: #{query}")

    @db.query(query).then((result)->
      result[0]
    )

module.exports = Tracker
