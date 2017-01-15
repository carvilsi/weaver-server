logger = require('logger')

# Known error codes are handled here
handler =
  'EADDRINUSE': (err) ->
    logger.error("Could not listen on port #{err.port} because it is in use.")
    process.exit(1)

    
# When code is unknown we default to this handler
unexpected = (err) ->
  logger.error("Unexpected #{err.stack}")

  
# Listen on error
process.on('uncaughtException', (err) ->
  if handler[err.code]?
    handler[err.code](err)
  else 
    unexpected(err)
)