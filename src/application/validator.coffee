module.exports = 
  hasFields: (object, fields) ->
    for field in fields
      if not object[field]?
        return false
    
    true
