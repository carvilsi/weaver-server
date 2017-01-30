typeShouldBe = (type) -> (val) ->
  Object.prototype.toString.call(val) is type

module.exports =
  
  isNumber: (val) ->
    typeShouldBe '[object Number]'
    
  isBoolean: (val) ->
    typeShouldBe '[object Boolean]'

  isObject: (val) ->
    typeShouldBe '[object Object]'

  isArray: (val) ->
    typeShouldBe '[object Array]'