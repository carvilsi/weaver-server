config     = require('config')
mysql      = require('mysql-promise')

class Tracker



  constructor: ->
    @db = mysql()
    @db.configure({
      host     : config.get('services.tracker.host')
      port     : config.get('services.tracker.port')
      user     : config.get('services.tracker.user')
      password : config.get('services.tracker.password')
      database : config.get('services.tracker.database')
    })

  checkInited: ->
    @db.query('SELECT * FROM `tracker` LIMIT 1;').then(
      (res)->
        return true;
      (error)->
        if error.code is 'ER_NO_SUCH_TABLE'
          return false
        else
          throw Error('not connected properly')
    )


  initDb: ->
    @checkInited().then((done)=>
      return Promise.resolve() if done
      @db.query('DROP TABLE IF EXISTS `tracker`;').then(=>
        @db.query('
          CREATE TABLE `tracker` (
          `seqnr` INT NOT NULL AUTO_INCREMENT,
          `timestamp` datetime  NOT NULL,
          `user` varchar(128) NOT NULL,
          `action` varchar(128) NOT NULL,
          `node` varchar(128) NOT NULL,
          `key` varchar(128) NULL,
          `to` varchar(128) NULL,
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
    query = 'INSERT INTO `trackerdb`.`tracker` (`timestamp`, `user`, `action`, `node`, `key`, `to`, `value`, `payload`) VALUES '
    quote = '\''

    for operation in writes

      timestamp = 'now()'
      user_id = quote + user.username + quote
      action = quote + operation.action + quote

      node_id = 'NULL'
      key = 'NULL'
      to = 'NULL'
      value = 'NULL'

      if operation.id?
        node_id = quote + operation.id + quote
      else if operation.from?
        node_id = quote + operation.from + quote
      if operation.key?
        key = quote + operation.key + quote
      if operation.to?
        to = quote + operation.to + quote
      if operation.value?
        value = @db.pool.escape(operation.value)

      payload = quote + JSON.stringify(operation) + quote

      query += "(#{timestamp}, #{user_id}, #{action}, #{node_id}, #{key}, #{to}, #{value}, #{payload}),"

    query = query.slice(0, -1)+';'

    @db.query(query)

  getHistoryFor: (req)->
    id = req.payload.id
    quote = '\''
    query = 'SELECT `seqnr`, `timestamp`, `user`, `action`, `node`, `key`, `to`, `value` FROM `trackerdb`.`tracker` WHERE `node` = ' + quote + id + quote + ';'
    @db.query(query).then((result)->
      result[0]
    )







module.exports = new Tracker()