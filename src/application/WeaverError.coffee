# Function that overloads error code into error message
Error = (code) -> (message) -> {code, message}
  
WeaverError = {}

#
# Error code indicating some error other than those enumerated here.
# @property OTHER_CAUSE
# @static
# @final
#
WeaverError.OTHER_CAUSE = Error(-1)

#
# Error code indicating that something has gone wrong with the server.
# If you get this error code, it is Weavers's fault. Contact us at
# https://weaverplatform.com/help
# @property INTERNAL_SERVER_ERROR
# @static
# @final
#
WeaverError.INTERNAL_SERVER_ERROR = Error(1)

#
# Error code indicating the connection to the Parse servers failed.
# @property CONNECTION_FAILED
# @static
# @final
#
WeaverError.CONNECTION_FAILED = Error(100)


# Error code indicating the specified Node doesn't exist.
WeaverError.NODE_NOT_FOUND = Error(101)

#
# Error code indicating you tried to query with a datatype that doesn't
# support it, like exact matching an array or object.
# @property INVALID_QUERY
# @static
# @final
#
WeaverError.INVALID_QUERY = Error(102)

#
# Error code indicating a missing or invalid classname. Classnames are
# case-sensitive. They must start with a letter, and a-zA-Z0-9_ are the
# only valid characters.
# @property INVALID_CLASS_NAME
# @static
# @final
#
WeaverError.INVALID_CLASS_NAME = Error(103)

#
# Error code indicating an unspecified object id.
# @property MISSING_OBJECT_ID
# @static
# @final
#
WeaverError.MISSING_OBJECT_ID = Error(104)

#
# Error code indicating an invalid key name. Keys are case-sensitive. They
# must start with a letter, and a-zA-Z0-9_ are the only valid characters.
# @property INVALID_KEY_NAME
# @static
# @final
#
WeaverError.INVALID_KEY_NAME = Error(105)

#
# Error code indicating a malformed pointer. You should not see this unless
# you have been mucking about changing internal Parse code.
# @property INVALID_POINTER
# @static
# @final
#
WeaverError.INVALID_POINTER = Error(106)

#
# Error code indicating that badly formed JSON was received upstream. This
# either indicates you have done something unusual with modifying how
# things encode to JSON, or the network is failing badly.
# @property INVALID_JSON
# @static
# @final
#
WeaverError.INVALID_JSON = Error(107)

#
# Error code indicating that the feature you tried to access is only
# available internally for testing purposes.
# @property COMMAND_UNAVAILABLE
# @static
# @final
#
WeaverError.COMMAND_UNAVAILABLE = Error(108)

#
# You must call Parse.initialize before using the Parse library.
# @property NOT_INITIALIZED
# @static
# @final
#
WeaverError.NOT_INITIALIZED = Error(109)

#
# Error code indicating that a field was set to an inconsistent type.
# @property INCORRECT_TYPE
# @static
# @final
#
WeaverError.INCORRECT_TYPE = Error(111)

#
# Error code indicating an invalid channel name. A channel name is either
# an empty string (the broadcast channel) or contains only a-zA-Z0-9_
# characters and starts with a letter.
# @property INVALID_CHANNEL_NAME
# @static
# @final
#
WeaverError.INVALID_CHANNEL_NAME = Error(112)

#
# Error code indicating that push is misconfigured.
# @property PUSH_MISCONFIGURED
# @static
# @final
#
WeaverError.PUSH_MISCONFIGURED = Error(115)

#
# Error code indicating that the object is too large.
# @property OBJECT_TOO_LARGE
# @static
# @final
#
WeaverError.OBJECT_TOO_LARGE = Error(116)

#
# Error code indicating that the operation isn't allowed for clients.
# @property OPERATION_FORBIDDEN
# @static
# @final
#
WeaverError.OPERATION_FORBIDDEN = Error(119)

#
# Error code indicating the result was not found in the cache.
# @property CACHE_MISS
# @static
# @final
#
WeaverError.CACHE_MISS = Error(120)

#
# Error code indicating that an invalid key was used in a nested
# JSONObject.
# @property INVALID_NESTED_KEY
# @static
# @final
#
WeaverError.INVALID_NESTED_KEY = Error(121)

#
# Error code indicating that an invalid filename was used for ParseFile.
# A valid file name contains only a-zA-Z0-9_. characters and is between 1
# and 128 characters.
# @property INVALID_FILE_NAME
# @static
# @final
#
WeaverError.INVALID_FILE_NAME = Error(122)

#
# Error code indicating an invalid ACL was provided.
# @property INVALID_ACL
# @static
# @final
#
WeaverError.INVALID_ACL = Error(123)

#
# Error code indicating that the request timed out on the server. Typically
# this indicates that the request is too expensive to run.
# @property TIMEOUT
# @static
# @final
#
WeaverError.TIMEOUT = Error(124)

#
# Error code indicating that the email address was invalid.
# @property INVALID_EMAIL_ADDRESS
# @static
# @final
#
WeaverError.INVALID_EMAIL_ADDRESS = Error(125)

#
# Error code indicating a missing content type.
# @property MISSING_CONTENT_TYPE
# @static
# @final
#
WeaverError.MISSING_CONTENT_TYPE = Error(126)

#
# Error code indicating a missing content length.
# @property MISSING_CONTENT_LENGTH
# @static
# @final
#
WeaverError.MISSING_CONTENT_LENGTH = Error(127)

#
# Error code indicating an invalid content length.
# @property INVALID_CONTENT_LENGTH
# @static
# @final
#
WeaverError.INVALID_CONTENT_LENGTH = Error(128)

#
# Error code indicating a file that was too large.
# @property FILE_TOO_LARGE
# @static
# @final
#
WeaverError.FILE_TOO_LARGE = Error(129)

#
# Error code indicating an error saving a file.
# @property FILE_SAVE_ERROR
# @static
# @final
#
WeaverError.FILE_SAVE_ERROR = Error(130)

#
# Error code indicating that a unique field was given a value that is
# already taken.
# @property DUPLICATE_VALUE
# @static
# @final
#
WeaverError.DUPLICATE_VALUE = Error(137)

#
# Error code indicating that a role's name is invalid.
# @property INVALID_ROLE_NAME
# @static
# @final
#
WeaverError.INVALID_ROLE_NAME = Error(139)

#
# Error code indicating that an application quota was exceeded.  Upgrade to
# resolve.
# @property EXCEEDED_QUOTA
# @static
# @final
#
WeaverError.EXCEEDED_QUOTA = Error(140)

#
# Error code indicating that a Cloud Code script failed.
# @property SCRIPT_FAILED
# @static
# @final
#
WeaverError.SCRIPT_FAILED = Error(141)

#
# Error code indicating that a Cloud Code validation failed.
# @property VALIDATION_ERROR
# @static
# @final
#
WeaverError.VALIDATION_ERROR = Error(142)

#
# Error code indicating that invalid image data was provided.
# @property INVALID_IMAGE_DATA
# @static
# @final
#
WeaverError.INVALID_IMAGE_DATA = Error(143)

#
# Error code indicating an unsaved file.
# @property UNSAVED_FILE_ERROR
# @static
# @final
#
WeaverError.UNSAVED_FILE_ERROR = Error(151)

#
# Error code indicating an invalid push time.
# @property INVALID_PUSH_TIME_ERROR
# @static
# @final
#
WeaverError.INVALID_PUSH_TIME_ERROR = Error(152)

#
# Error code indicating an error deleting a file.
# @property FILE_DELETE_ERROR
# @static
# @final
#
WeaverError.FILE_DELETE_ERROR = Error(153)

#
# Error code indicating that the application has exceeded its request
# limit.
# @property REQUEST_LIMIT_EXCEEDED
# @static
# @final
#
WeaverError.REQUEST_LIMIT_EXCEEDED = Error(155)

#
# Error code indicating an invalid event name.
# @property INVALID_EVENT_NAME
# @static
# @final
#
WeaverError.INVALID_EVENT_NAME = Error(160)


# Error code indicating a that a Node with given ID can't be recreated again
WeaverError.NODE_ALREADY_EXISTS = Error(161)


#
# Error code indicating that the username is missing or empty.
# @property USERNAME_MISSING
# @static
# @final
#
WeaverError.USERNAME_MISSING = Error(200)

#
# Error code indicating that the password is missing or empty.
# @property PASSWORD_MISSING
# @static
# @final
#
WeaverError.PASSWORD_MISSING = Error(201)

#
# Error code indicating that the username has already been taken.
# @property USERNAME_TAKEN
# @static
# @final
#
WeaverError.USERNAME_TAKEN = Error(202)

#
# Error code indicating that the email has already been taken.
# @property EMAIL_TAKEN
# @static
# @final
#
WeaverError.EMAIL_TAKEN = Error(203)

#
# Error code indicating that the email is missing, but must be specified.
# @property EMAIL_MISSING
# @static
# @final
#
WeaverError.EMAIL_MISSING = Error(204)

#
# Error code indicating that a user with the specified email was not found.
# @property EMAIL_NOT_FOUND
# @static
# @final
#
WeaverError.EMAIL_NOT_FOUND = Error(205)

#
# Error code indicating that a user object without a valid session could
# not be altered.
# @property SESSION_MISSING
# @static
# @final
#
WeaverError.SESSION_MISSING = Error(206)

#
# Error code indicating that a user can only be created through signup.
# @property MUST_CREATE_USER_THROUGH_SIGNUP
# @static
# @final
#
WeaverError.MUST_CREATE_USER_THROUGH_SIGNUP = Error(207)

#
# Error code indicating that an an account being linked is already linked
# to another user.
# @property ACCOUNT_ALREADY_LINKED
# @static
# @final
#
WeaverError.ACCOUNT_ALREADY_LINKED = Error(208)

#
# Error code indicating that the current session token is invalid.
# @property INVALID_SESSION_TOKEN
# @static
# @final
#
WeaverError.INVALID_SESSION_TOKEN = Error(209)

#
# Error code indicating that a user cannot be linked to an account because
# that account's id could not be found.
# @property LINKED_ID_MISSING
# @static
# @final
#
WeaverError.LINKED_ID_MISSING = Error(250)

#
# Error code indicating that a user with a linked (e.g. Facebook) account
# has an invalid session.
# @property INVALID_LINKED_SESSION
# @static
# @final
#
WeaverError.INVALID_LINKED_SESSION = Error(251)

#
# Error code indicating that a service being linked (e.g. Facebook or
# Twitter) is unsupported.
# @property UNSUPPORTED_SERVICE
# @static
# @final
#
WeaverError.UNSUPPORTED_SERVICE = Error(252)

#
# Error code indicating that there were multiple errors. Aggregate errors
# have an "errors" property, which is an array of error objects with more
# detail about each error that occurred.
# @property AGGREGATE_ERROR
# @static
# @final
#
WeaverError.AGGREGATE_ERROR = Error(600)

#
# Error code indicating the client was unable to read an input file.
# @property FILE_READ_ERROR
# @static
# @final
#
WeaverError.FILE_READ_ERROR = Error(601)

#
# Error code indicating a real error code is unavailable because
# we had to use an XDomainRequest object to allow CORS requests in
# Internet Explorer, which strips the body from HTTP responses that have
# a non-2XX status code.
# @property X_DOMAIN_REQUEST
# @static
# @final
#
WeaverError.X_DOMAIN_REQUEST = Error(602)
  

module.exports = WeaverError