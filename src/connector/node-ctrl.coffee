OperationHandler = require('OperationHandler')

bus     = require('event-bus').get('weaver')
handler = new OperationHandler()

    
bus.on('read', (req, res)->
  res.promise(handler.readNode(req.payload))
)

bus.on('write', (req, res)->
  res.promise(handler.write(req.payload))
)