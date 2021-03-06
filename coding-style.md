Coding Style Guide
==================

The intent of this guide is to reduce cognitive friction when scanning code
from different authors. It does so by enumerating a shared set of rules and
expectations about how to format the Weaver Server CoffeeScript code.

Remember, when you write software, you write for your audience. Your audience is the maintenance developer, which may be you after 3 years after you have forgotten the details of how it all works.

1. Overview
-----------

- Use 2 spaces for indenting, not tabs.

- Always end a file with a new line.

(NEW) - Files in nodejs project are dash-saperated, except for files with classes.

- Files that export a class are UpperCamelCased. All other files are camelCased.

- Class names are UpperCamelCased.

- All atributes are camelCased. Don't use underscores.

- Do not use console.log but use the logger by logger = require('logger').
- When defining a function with no arguments, omit the () before the arrow ->

- Don't use fat arrows for functions when @ is not used.

- In general, try to always use function brackets like randomInt(4) instead of randomInt 4. In very rare cases (like testing with mocha) it is favorable to omit the brackets, like in it 'should test this', ->

- When using variables in strings, it is preferred to use "Hello #{user}" instead of "Hello" + user, especially when having lots of variables.

- Do not try/catch and then just log the error, but rethrow or reject a promise to let the callee handle it.

- Chaining promises: Prefer
```
somePromise(...).then((r) ->
  someOtherPromise(r)
).then((q) ->
  resultReturning(q)
)
```
over
```
somePromise(...).then((r) ->
  someOtherPromise(r).then((q) ->
    resultReturning(q)
  )
)
```
This keeps the promise nesting shallow and code more cleanly separated.


See .editorconfig file below that you can use:

```
# http://editorconfig.org

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
indent_style = tab
```

2. Logging
----------

- Use these loggers

  - config: some configuration setting is invalid or some availability requirement is, or is no longer, met. e.g. `logger.config.error("No connection to database")`
  - usage: some method is being used with the wrong inputs, or in a wrong state. e.g. `logger.usage.warn("Incorrect payload")`
  - code: related with developing process, e.g. for debugging purposes `logger.code.debug("print this")`

	For each one you can use the next levels:

		- error
		- warn
		- info
		- verbose
		- debug
		- silly

3. Microservices
----------------

- Serve a json with version information at /about

- Check availability and version of required services on startup

- Serve availability at /connection (?)

- Inform monitoring system on unrecoverable crash and trigger external recovery
