# More natural way of delaying functions
module.exports = (ms, func) ->
    setTimeout(func, ms)