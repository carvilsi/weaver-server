WEAVER = require('route-registry').get("weaver")
ADMIN  = require('route-registry').get("admin")


# Weaver routes
WEAVER.GET   ""                       # Index page                                        
WEAVER.GET   "application.version"    # Application version

WEAVER.GET   "read"                   # Reads a single entity
WEAVER.POST  "create"                 # Creates a new entity
WEAVER.POST  "update"                 # Sets a new property field
WEAVER.POST  "removeAttribute"        # Removes a key from an entity            destroyAttribute
WEAVER.POST  "link"                   # Creates a relation between two entities
WEAVER.POST  "unlink"                 # Removes a relation between two entities
WEAVER.POST  "destroyEntity"          # Destroys entity

WEAVER.GET   "chirqlQuery"            # Execute ChirQL read query
WEAVER.GET   "nativeQuery"            # Native query of underlying database
WEAVER.POST  "bulk"                   # Execute CRUD operations in bulk    (bootstrapFromJson?)

# Admin routes
ADMIN.POST   "wipe"                   # Wipe entire database