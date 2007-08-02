This profile will create a site suitable for testing patches for Drupal.org.
It was originally based on the development profile.

* Will install devel and devel_node_access along the default nodes.
* Creates users, content and comments using the devel.module's generate API.
* Creates uid 1 user with "a" as username and password and logs it in.

Required modules and versions for Drupal 5.x as of July 30, 2007:
    
    * codefilter DRUPAL-5 
    * cvslog HEAD
    * devel DRUPAL-5
    * project HEAD
    * project_issue HEAD

Before installing with this profile, download or checkout these
modules to sites/all/modules, sites/default/modules, or another
appropriate location.

$Id$
