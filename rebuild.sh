#!/bin/bash
#
# This script is based on Open Atrium's rebuild script.
#
# To use this command you must have `drush make`, `cvs` and `git` installed.
#

if [ -f drupalorg_testing.make ]; then
  echo -e "\nThis command can be used to run drupalorg_testing.make in place, or to generate"
  echo -e "a complete distribution of Drupal.org Testing.\n\nWhich would you like?"
  echo "  [1] Rebuild Drupal.org Testing in place."
  echo "  [2] Build a full Drupal.org Testing distribution"
  echo -e "Selection: \c"
  read SELECTION

  if [ $SELECTION = "1" ]; then

    # Run drupalorg_testing.make only.
    echo "Building Drupal.org Testing install profile..."
    drush make --working-copy --no-core --contrib-destination=. drupalorg_testing.make --yes

  elif [ $SELECTION = "2" ]; then

    # Generate a complete tar.gz of Drupal + Drupal.org Testing
    echo "Building Drupal.org Testing distribution..."

MAKE=$(cat <<EOF
core = "6.x"\n
api = 2\n
projects[drupal][version] = "6.19"\n
projects[drupalorg_testing][type] = "profile"\n
projects[drupalorg_testing][download][type] = "git"\n
projects[drupalorg_testing][download][url] = "http://github.com/shomeya/drupalorg_testing.git"\n
EOF
)
    VERSION=`date +%Y%m%d%H%M%S`
    MAKE="$MAKE $TAG\n"
    NAME=`echo "drupalorg_testing-$VERSION" | tr '[:upper:]' '[:lower:]'`
    echo -e $MAKE | drush make --yes --tar - $NAME
  else
   echo "Invalid selection."
  fi
else
  echo 'Could not locate file "drupalorg_testing.make"'
fi
