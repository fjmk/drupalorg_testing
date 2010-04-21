; $Id$

; make file for drupalorg_testing profile
core = 6.x
projects[] = drupal


; Profile.

projects[drupalorg_testing][download][type] = "cvs"
projects[drupalorg_testing][download][module] = "contributions/profiles/drupalorg_testing"
projects[drupalorg_testing][download][revision] = "HEAD"


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

