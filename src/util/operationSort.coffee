module.exports = (a, b) ->
  res = a.timestamp - b.timestamp
  if res is 0
    res += 1 if b.action is 'create-node'
    res += -1 if a.action is 'create-node'
  res
