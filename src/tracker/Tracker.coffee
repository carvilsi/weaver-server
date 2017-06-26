config     = require('config')
mysql      = require('mysql-promise')
Promise    = require('bluebird')
logger     = require('logger')
my         = require('mysql')

class Tracker

  constructor: (tracker) ->
    @tries = 10
    @delay = 5000
    @db = mysql()
    @initConfirmed = false
    @db.configure({
      host     : tracker.host
      port     : tracker.port
      user     : tracker.user
      password : tracker.password
      database : 'trackerdb'
      dateStrings: true # force dates as string, no javascript date
    })


  checkInitialized: ->
    return Promise.resolve(true) if @initConfirmed
    logger.code.debug("Trying to connect to trackerdb on #{'services.tracker.host'}")
    delay = 5000
    @db.query('SELECT * FROM `tracker` LIMIT 1;')
    .then(=>
      @initConfirmed = true
    ).catch((error)=>
      if error.code is 'ER_NO_SUCH_TABLE'
        false
      else
        if @tries-- > 0
          Promise.delay(@delay).then(=>@checkInitialized())
        else
          Promise.reject("Tracker could not connect to mysql database, #{error.code}. Tried with #{'services.tracker.user'}@#{'services.tracker.host'}:#{'services.tracker.port'} with pass #{'services.tracker.password'}")
    )

  wipe: ->
    @checkInitialized().then((done) =>
      @db.query('TRUNCATE TABLE `tracker`;') if done
    )

  initDb: ->
    @checkInitialized().then((done)=>
      return Promise.resolve() if done
      logger.code.debug "Dropping and creating table"
      @db.query('DROP TABLE IF EXISTS `tracker`;')
      .then(=>
        logger.code.debug "Creating table"
        @db.query('
          CREATE TABLE `tracker` (
          `seqnr` BIGINT NOT NULL AUTO_INCREMENT,
          `timestamp` BIGINT  NOT NULL,
          `datetime` datetime  NOT NULL,
          `user` varchar(128) NOT NULL,
          `action` varchar(128) NOT NULL,
          `node` varchar(128) NULL,
          `key` varchar(128) NULL,
          `from` varchar(128) NULL,
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
      ).then(=>
        @initConfirmed = true
      )
    )

  processWrites: (writes, user, project)->
    @initDb().then(=>
      if not writes? or writes.length < 1
        return Promise.resolve()

      query = 'INSERT INTO `tracker` (`timestamp`, `datetime`, `user`, `action`, `node`, `key`, `from`, `to`, `oldTo`, `value`, `payload`) VALUES '

      for operation in writes
        insert = @trackerize(operation, user)
        query += "(#{my.escape(insert.timestamp)}, FROM_UNIXTIME(#{my.escape(insert.datetime)}), #{my.escape(insert.user_id)}, #{my.escape(insert.action)}, #{my.escape(insert.node_id)}, #{my.escape(insert.key)}, #{my.escape(insert.from)}, #{my.escape(insert.to)}, #{my.escape(insert.old_to)}, #{my.escape(insert.value)}, #{my.escape(insert.payload)}),"

      query = query.slice(0, -1)+';'

      @db.query(query)
    )

  trackerize: (operation, user)->

    quote = '\''
    insert = {}

    insert.timestamp = operation.timestamp
    insert.datetime = Math.round(operation.timestamp / 1000)
    insert.user_id = quote + user.id + quote
    insert.action = quote + operation.action + quote
    insert.payload = @db.pool.escape(JSON.stringify(operation))

    insert.node_id = 'NULL'
    insert.key = 'NULL'
    insert.from = 'NULL'
    insert.to = 'NULL'
    insert.old_to = 'NULL'
    insert.value = 'NULL'

    if operation.action is 'create-node'
      insert.node_id = quote + operation.id + quote

    if operation.action is 'remove-node'
      insert.node_id = quote + operation.id + quote

    if operation.action is 'create-attribute'
      insert.node_id = quote + operation.id + quote
      insert.key     = quote + operation.key + quote
      insert.value   = @db.pool.escape(operation.value)

    if operation.action is 'update-attribute'
      insert.node_id = quote + operation.id + quote
      insert.key     = quote + operation.key + quote
      insert.value = @db.pool.escape(operation.value)

    if operation.action is 'remove-attribute'
      insert.node_id = quote + operation.id + quote
      insert.key     = quote + operation.key + quote

    if operation.action is 'create-relation'
      insert.node_id = quote + operation.id + quote
      insert.from    = quote + operation.from + quote
      insert.key     = quote + operation.key + quote
      insert.to      = quote + operation.to + quote

    if operation.action is 'update-relation'
      insert.from    = quote + operation.from + quote
      insert.key     = quote + operation.key + quote
      insert.old_to  = quote + operation.oldTo + quote
      insert.to      = quote + operation.newTo + quote

    if operation.action is 'remove-relation'
      insert.from    = quote + operation.from + quote
      insert.key     = quote + operation.key + quote
      insert.to      = quote + operation.to + quote

    insert



  getHistoryFor: (req)->
    @initDb().then( =>
      quote = '\''
      conditions = []
      query = 'SELECT `seqnr`, `datetime`, `user`, `action`, `node`, `key`, `from`, `to`, `oldTo`, `value` FROM `tracker`'

      if req.payload.users?
        conditions.push('`user` IN (' + quote + (my.escape(u) for u in req.payload.users).join(quote + ', ' + quote) + quote + ')')

      if req.payload.ids?
        conditions.push('`node` IN (' + quote + (my.escape(i) for i in req.payload.ids).join(quote + ', ' + quote) + quote + ')')

      if req.payload.keys?
        conditions.push('`key` IN (' + quote + (my.escape(i) for i in req.payload.keys).join(quote + ', ' + quote) + quote + ')')

      if req.payload.fromDateTime?
        conditions.push('`datetime` >= ' + quote + my.escape(req.payload.fromDateTime) + quote)

      if req.payload.beforeDateTime?
        conditions.push('`datetime` < ' + quote + my.escape(req.payload.beforeDateTime) + quote)

      if conditions.length > 0
        query = query.concat(' WHERE ' + conditions.join(' AND '))

      query = query.concat(' ORDER BY `seqnr` ASC')

      if req.payload.limit?
        query = query.concat(" limit #{my.escape(req.payload.limit)}")

      query = query.concat(';')

      logger.code.debug("The query: #{query}")

      @db.query(query).then((result)->
        result[0]
      )
    )

module.exports = Tracker
