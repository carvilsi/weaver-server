module.exports = (bus) ->

  bus.private("countNodes").retrieve('project').on((req, project) ->
    500 # TODO, implement count on WeaverQuery
  )
