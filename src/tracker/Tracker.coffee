config     = require('config')
Promise    = require('bluebird')
logger     = require('logger')
my         = require('mysql')

class Tracker

  constructor: (@database) ->

  countHistoryRows: ->
    query = "SELECT COUNT(*) FROM \"trackerdb\";"
    @database.postgresQuery(query)

  getHistoryFor: (req) ->
    logger.usage.debug "History request: #{JSON.stringify(req)}"
    quote = '\''
    conditions = []
    query = "SELECT * FROM \"trackerdb\""

    if req.payload.users?
      conditions.push('"user" IN (' + (my.escape(u) for u in req.payload.users).join(', ') + ')')

    if req.payload.ids?
      conditions.push('"node" IN (' + (my.escape(i) for i in req.payload.ids).join(', ') + ')')

    if req.payload.keys?
      conditions.push('"key" IN (' + (my.escape(i) for i in req.payload.keys).join(', ') + ')')

    if req.payload.froms?
      conditions.push('"from" IN (' + (my.escape(i) for i in req.payload.froms).join(', ') + ')')

    if req.payload.tos?
      conditions.push('"to" IN (' + (my.escape(i) for i in req.payload.tos).join(', ') + ')')

    if req.payload.fromDateTime?
      conditions.push('"datetime" >= ' + my.escape(req.payload.fromDateTime))

    if req.payload.beforeDateTime?
      conditions.push('"datetime" < ' + my.escape(req.payload.beforeDateTime))

    if conditions.length > 0
      if req.payload.booleanOperator? and req.payload.booleanOperator is 'or'
        query = query.concat(' WHERE ' + conditions.join(' OR '))
      else
        query = query.concat(' WHERE ' + conditions.join(' AND '))

    if req.payload.sorted? and req.payload.sorted is 'descending'
      query = query.concat(' ORDER BY "seqnr" DESC')
    else
      query = query.concat(' ORDER BY "seqnr" ASC')

    if req.payload.offset?
      query = query.concat(" OFFSET #{my.escape(req.payload.offset)}")

    if req.payload.limit?
      query = query.concat(" LIMIT #{my.escape(req.payload.limit)}")

    query = query.concat(';')

    logger.code.debug("The query: #{query}")

    @database.postgresQuery(query)


module.exports = Tracker
