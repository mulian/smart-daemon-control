#!/bin/sh

echo "This add-to-atom Bash Script works currently only with Mac OS X.\n"

USER=$(id -un)
ATOM="/Users/$USER/.atom/"
ATOM_PACKAGES="${ATOM}packages/"
PACKAGE_NAME=${PWD##*/} #aka. Dirname
ATOM_PACKAGE="${ATOM_PACKAGES}${PACKAGE_NAME}"

if [ -n "$1"  ] && [ "$1" = "-f" ]; then
  FORCE=true
fi

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR_PATH/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Check if Package already in Atom
if [ -z "$FORCE" ] && ([ -L "$ATOM_PACKAGE" ] || [ -d "$ATOM_PACKAGE"]); then
  echo "There is alrady a package with Name '${PACKAGE_NAME}'."
  echo "Use -f (FORCE) to overwrite"
  exit -1;
elif ! [ -d "$ATOM" ]; then
  echo "There is no Atom. :)"
  exit -1;
elif [ -n "$FORCE" ] && ([ -L "$ATOM_PACKAGE" ] || [ -d "$ATOM_PACKAGE"]); then
  # Force remove current Atom Package
  rm $ATOM_PACKAGE
fi

echo "Add symlink\n"
# Add this Package with symlink to Atom Packages
ln -s $DIR_PATH $ATOM_PACKAGE

echo "Ready, restart Atom"
