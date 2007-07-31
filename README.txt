This profile will create a site suitable for testing patches for Drupal.org. It
is based on the development profile.

The code I stole from development profile:
* Will install devel and devel_node_access along the default nodes.
* Creates users and content+comments as well with the devel package generate
scripts.
* Creates uid 1 user with "a" as username and password and logs it in.

Required modules and versions for Drupal 5.x as of July 30, 2007:
    
    * codefilter DRUPAL-5 
    * cvslog HEAD.
    * devel DRUPAL-5
    * project HEAD
    * project_issue HEAD

Before installing with this profile download or checkout these modules to sites/all/modules, 
sites/default/modules, or another appropriate location. 

