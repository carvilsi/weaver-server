config          = require('config')
mysql      = require('mysql-promise')




class Tracker

  constructor: ->
#    console.log(config.get('services.tracker.enabled'))
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
          `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
          `foobar` varchar(128) NOT NULL,
          PRIMARY KEY (`id`)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
        )
      )
    )



  test: ->
    @db.query('SELECT * FROM `tracker` LIMIT 1;')

  processWrites: (writes)->
    console.log(writes)





module.exports = Tracker