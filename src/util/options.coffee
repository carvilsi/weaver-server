module.exports =
  
  # Sets default options on an options object by passing in an array with key,value tuple defaults
  defaults: (options, defaultOptions) ->
    for key, value of defaultOptions
      options[key] = value if not options[key]?