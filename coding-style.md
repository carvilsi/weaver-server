Coding Style Guide
==================

The intent of this guide is to reduce cognitive friction when scanning code
from different authors. It does so by enumerating a shared set of rules and
expectations about how to format the Weaver Server CoffeeScript code.

1. Overview
-----------

- Use 2 spaces for indenting, not tabs.

- Always end a file with a new line

- Files that export a class are UpperCamelCased. All other files are camelCased.

- Class names are UpperCamelCased. 

- All atributes are camelCased. Don't use underscores.

- Do not use console.log but use the logger by logger = require('logger').
- When defining a function with no arguments, omit the () before the arrow ->

- Don't use fat arrows for functions when @ is not used.

- In general, try to always use function brackets like randomInt(4) instead of randomInt 4. In very rare cases (like testing with mocha) it is favorable to omit the brackets, like in it 'should test this', ->

- When using variables in strings, it is preferred to use "Hello #{user}" instead of "Hello" + user, especially when having lots of variables.

- Do not try/catch and then just log the error, but rethrow or reject a promise to let the callee handle it.


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
