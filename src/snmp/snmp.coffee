snmp    = require('snmpjs')
dgram   = require('dgram')
os      = require('os')
logger  = require('logger')
config  = require('config')

request_id = 0

socket = dgram.createSocket('udp4')

sendTrap = ->
  varBind = snmp.varbind.createVarbind({
    oid: '.1.3.6.1.4.1.20749.1.1.3.47'
    data: snmp.data.createData(
      type: 'OctetString'
      value: 'WeaverServer working')
  })
  trap = snmp.message.createMessage({
    version: 1 # SNMPv2
    community: 'public'
    pdu: snmp.pdu.createPDU({
      op: 7 # SNMPv2-Trap-PDU
      request_id
      varbinds: varBind
      agent_addr: config.get('services.snmp.agentAddress').toString()
      time_stamp: new Date().valueOf()
    })
  })

  request_id = (request_id + 1) % 5000

  trap.encode()

  socket.send(trap._raw.buf,0,trap._raw.len,parseInt(config.get('services.snmp.trapPort')),config.get('services.snmp.ipMonitor').toString(), (err, bytes)->
    if (err)
      logger.code.error(err)
    else
      logger.code.debug(bytes+' bytes writen to trap')
  )


agent = snmp.createAgent()


###
 requseting the heartbeat status
###

agent.request
  oid: '.1.3.6.1.4.1.20749.1.1.3.47'
  handler: (prq) ->
    val = snmp.data.createData(
      type: 'OctetString'
      value: 'Weaver Server working')
    snmp.provider.readOnlyScalar prq, val
    return



if config.get('services.snmp.enabled')
  agent.bind
    family: 'udp4'
    port: parseInt(config.get('services.snmp.agentPort'))
    addr: config.get('services.snmp.agentAddress').toString()

  setInterval(sendTrap,config.get('services.snmp.heartbeatsInterval'))
