# Functions to change the terminal cursor
module.exports=
  clear: ->
    console.log(`'\033[2J'`)
    
  toTop: ->
    console.log(`'\033[0;0H'`)
    
  moveUp: ->
    console.log(`'\033[3A'`)