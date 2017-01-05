
class RouteHandler

  constructor: (@name) ->
    @getRoutes  = []
    @postRoutes = []
    @bus        = require('EventBus').get(@name)

  GET: (route) ->
    @getRoutes.push(route)
    
  POST: (route) ->
    @postRoutes.push(route)
    
  allRoutes: ->
    @getRoutes.concat(@postRoutes)
    
  handleRequest: (route, req, res) ->
    # Test payload
    console.log("Handling route: #{route}")
    try
      req.payload = JSON.parse(req.payload)
    catch error
      console.log(error)
      #res.send(ERROR('invalid json payload', req.payload))
      return


    # Add promise call
    res.promise = (promise) ->
      promise.then((response) ->
        response = "OK" if not response?
        res.send(response)
      ).catch((err) ->
        res.error(err)
      )

    @bus.emit(route, req, res)


Registry = require('registry')
module.exports = new Registry(RouteHandler)
