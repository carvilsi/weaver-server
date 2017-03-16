config = require('config')
player = require('play-sound')()

# Checks if sound is enabled through config
enabled = (name) ->
  config.get("application.sounds.#{name}")

# Checks if all sounds should be muted
muted = ->
  enabled("muteAll")

# Play sounds by filename in the sounds folder
play = (file) ->
  player.play("sounds/#{file}") if not muted()

# Export sounds
module.exports =
  loaded: ->
    play "chirp.wav" if enabled('loaded')
