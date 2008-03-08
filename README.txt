This profile will create a site suitable for testing patches for Drupal.org.
It was originally based on the development profile.

Required modules and versions for Drupal 5.x as of March 8th, 2008:
    
    * codefilter DRUPAL-5 
    * cvslog DRUPAL-5
    * devel DRUPAL-5
    * project DRUPAL-5
    * project_issue DRUPAL-5--2 or DRUPAL-5
    * comment_upload DRUPAL-5 (if using DRUPAL-5--2 of project_issue)

You can also use the HEAD branch of both project and project_issue for
now, until we directly start making changes for the 6.x core API.

Before installing with this profile, download or checkout these
modules to sites/all/modules, sites/default/modules, or another
appropriate location.

In addition to installing core and enabling these modules, the profile
performs the following additional setup:

* Creates the site super-user (uid 1) and logs it in.  By default, the
  username and password are both "a", but you can alter this by
  changing the "D_O_USER1" and "D_O_PASSWORD" constants at the top of
  the drupalorg_testing.profile file.
* Creates the role and permission structure used on drupal.org.
* Creates a few well-known users for each special role, and gives all
  of them the ability to switch back and forth using the "Switch user"
  functionality provided by the devel.module.
* Creates other random users (which don't belong to any special role).
* Generates random content and comments using the devel.module's API.
* Configures the project classification system used on drupal.org.
* Creates a handful of project nodes of all different types.
* Configures the settings to mimic the CVS repositories for the
  projects (a future version of this profile will actually provide a
  stub CVS repository for more advanced testing, for now, it just
  pretends that there's a CVS repository connected to the site).
  Each of the well-known users has a corresponding CVS account.
* Configures other project, menu, and block settings like drupal.org.
* Creates a set of random issues, and if you use the 5.x-2.* series of
  project_issue, some random comments on those issues.


$Id$
