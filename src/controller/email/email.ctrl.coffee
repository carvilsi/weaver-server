email   = require("emailjs/email");

module.exports =

  class EmailCtrl
    send: (payload, socket, ack) ->

      server  = email.server.connect(
        user:     payload.user
        password: payload.password
        host:     payload.host
        ssl:      false
      )

      server.send({
          from:    payload.from
          to:      payload.sendTo
          subject: payload.subject
          attachment:
            [
              {data: payload.message, alternative:true}
            ]
        }, (err, message) ->
          if err
            console.log(err)
            ack('error')
          else
            ack('OK')
      )