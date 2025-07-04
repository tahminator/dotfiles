#!/bin/bash

# easy way to clean up all the java generated files,
# if you need to coerce nvim-jdtls to work properly!

find . -name ".project" -exec rm {} +
find . -name ".classpath" -exec rm {} +
find . -name ".factorypath" -exec rm {} +
find . -type d -name ".settings" -exec rm -r {} +
find . -type d -name ".gradle" -exec rm -r {} +
find . -type d -name "bin" -exec rm -r {} +
find . -type d -name "build" -exec rm -r {} +
find . -type d -name "generated" -exec rm -r {} +

echo "Clean-up complete!"
