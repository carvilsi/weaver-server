# Export a function with the bus injected
# Using a plugin always requires a signed in user. Therefore, public routes are disabled
# You may return a promise if you need asynchronous initialization
module.exports = (bus) ->

  bus.private("getBase").on((req) ->
    "Base-10"
  )

  bus.private('add').require('x', 'y').on((req, x, y) ->
    x + y
  )

  bus.private('subtract').require('x', 'y').on((req, x, y) ->
    x - y
  )
