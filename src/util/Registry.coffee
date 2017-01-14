module.exports=
class Registry

  constructor: (@Type) ->
    @registry = {}
  
  get: (name) ->
    if not @registry[name]?
      @registry[name] = new @Type(name)
  
    @registry[name]