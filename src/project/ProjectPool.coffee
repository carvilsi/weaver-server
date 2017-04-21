config = require('config')

# Switch between the different project pools
module.exports =
  if config.get('application.singleDatabase')
  then require('./FixedProjectPool')
  else require('./KubernetesProjectPool')
