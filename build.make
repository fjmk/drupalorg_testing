; Grab the drupalorg_testing install profile and build it out.
api = 2
core = 6.x

projects[drupal][type] = core
projects[drupal][version] = "6.19"
projects[drupal][patch][] = "http://drupalcode.org/viewvc/drupal/contributions/modules/simpletest/D6-core-simpletest.patch?revision=1.1.2.11&content-type=text/plain&view=co&pathrev=DRUPAL-6--2"
projects[drupal][patch][] = "http://pub.shomeya.com/misc/do_core_simpletest_settings.patch"

projects[drupalorg_testing][type] = "profile"
projects[drupalorg_testing][download][type] = "git"
projects[drupalorg_testing][download][url] = "http://github.com/shomeya/drupalorg_testing.git"