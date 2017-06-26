bus = require('WeaverBus')

bus.private('query').retrieve('user', 'database').on((req, user, database) ->

  database.query(req.payload.query).then((results) ->

    #TODO Check permission per node before returning results
    results
  )
)

bus.private('query.native')
.retrieve('user', 'database')
.on((req, user, database) ->
  
  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  database.nativeQuery(req.payload.query)
)
