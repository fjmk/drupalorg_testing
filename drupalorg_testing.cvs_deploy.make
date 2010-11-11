; $Id$
api = 2


; make file for drupalorg_testing profile
core = 6.x
projects[drupal][patch][] = "http://drupalcode.org/viewvc/drupal/contributions/modules/simpletest/D6-core-simpletest.patch?revision=1.1.2.11&content-type=text/plain&view=co&pathrev=DRUPAL-6--2"


; Profile.

projects[drupalorg_testing][type] = "profile"
projects[drupalorg_testing][download][type] = "git"
projects[drupalorg_testing][download][url] = "git://github.com/shomeya/drupalorg_testing.git"


; Modules.

projects[project][download][type] = "cvs"
projects[project][download][module] = "contributions/modules/project"
projects[project][download][revision] = "HEAD"

projects[project_issue][download][type] = "cvs"
projects[project_issue][download][module] = "contributions/modules/project_issue"
projects[project_issue][download][revision] = "HEAD"

projects[install_profile_api][download][type] = "cvs"
projects[install_profile_api][download][module] = "contributions/modules/install_profile_api"
projects[install_profile_api][download][revision] = "DRUPAL-6--2"

projects[codefilter][download][type] = "cvs"
projects[codefilter][download][module] = "contributions/modules/codefilter"
projects[codefilter][download][revision] = "DRUPAL-6--1"

projects[cvslog][download][type] = "cvs"
projects[cvslog][download][module] = "contributions/modules/cvslog"
projects[cvslog][download][revision] = "HEAD"

projects[devel][download][type] = "cvs"
projects[devel][download][module] = "contributions/modules/devel"
projects[devel][download][revision] = "DRUPAL-6--1"

projects[views][download][type] = "cvs"
projects[views][download][module] = "contributions/modules/views"
projects[views][download][revision] = "DRUPAL-6--2"

projects[comment_upload][download][type] = "cvs"
projects[comment_upload][download][module] = "contributions/modules/comment_upload"
projects[comment_upload][download][revision] = "DRUPAL-6--1"

projects[comment_alter_taxonomy][download][type] = "cvs"
projects[comment_alter_taxonomy][download][module] = "contributions/modules/comment_alter_taxonomy"
projects[comment_alter_taxonomy][download][revision] = "HEAD"

projects[simpletest][download][type] = "cvs"
projects[simpletest][download][module] = "contributions/modules/simpletest"
projects[simpletest][download][revision] = "DRUPAL-6--2"

projects[cvs_deploy][download][type] = "cvs"
projects[cvs_deploy][download][module] = "contributions/modules/cvs_deploy"
projects[cvs_deploy][download][revision] = "DRUPAL-6--1"


; Version control API

projects[autoload][download][type] = "cvs"
projects[autoload][download][module] = "contributions/modules/autoload"
projects[autoload][download][revision] = "DRUPAL-6--2"

projects[dbtng][download][type] = "cvs"
projects[dbtng][download][module] = "contributions/modules/dbtng"
projects[dbtng][download][revision] = "DRUPAL-6--1"

projects[versioncontrol][download][type] = "cvs"
projects[versioncontrol][download][module] = "contributions/modules/versioncontrol"
projects[versioncontrol][download][revision] = "HEAD"

projects[versioncontrol_git][download][type] = "cvs"
projects[versioncontrol_git][download][module] = "contributions/modules/versioncontrol_git"
projects[versioncontrol_git][download][revision] = "DRUPAL-6--2"
