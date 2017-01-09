OperationHandler = require('OperationHandler')

bus     = require('EventBus').get('weaver')
handler = new OperationHandler()

    
bus.on('read', (req, res)->
  handler.readNode(req.payload)
)

bus.on('write', (req, res)->
  handler.write(req.payload)
)