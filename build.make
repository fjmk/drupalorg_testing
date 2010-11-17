; Grab the drupalorg_testing install profile and build it out.
api = 2
core = 6.x

projects[drupal][type] = core
projects[drupal][version] = "6.19"

projects[drupalorg_testing][type] = "profile"
projects[drupalorg_testing][download][type] = "git"
projects[drupalorg_testing][download][url] = "http://github.com/shomeya/drupalorg_testing.git"