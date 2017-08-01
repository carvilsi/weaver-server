config = require('config')

# Switch between the different project pools
module.exports = require("./#{config.get('application.projectpool')}")
