errors = 
  "invalid json payload":
    code: 1
    message: "Invalid JSON payload object supplied"



    
module.exports = (name, payload) ->
  # Clone error to prevent changing
  error = JSON.parse(JSON.stringify(errors[name]))
  
  # Attach payload object if given
  error.payload = payload if payload?
  error