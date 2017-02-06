# Object to capture process exits and call app specific cleanup function

module.exports = (callback) ->

  # Attach user callback to the process event emitter
  # If no callback, it will still exit gracefully on Ctrl-C
  callback = callback or (->);
  process.on('cleanup',callback)

  # Do app specific cleaning before exiting
  process.on('exit', ->
    process.emit('cleanup')
  )

  # Catch ctrl+c event and exit normally
  process.on('SIGINT', ->
    process.exit(2)
  )

  # Catch uncaught exceptions, trace, then exit normally
  process.on('uncaughtException', (e) ->
    console.log(e.stack)
    process.exit(99)
  )
