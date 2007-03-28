<?php

function drupalorg_testing_profile_modules() {
  return array(
    'block', 'color', 'comment', 'filter', 'help', 'menu', 'node', 'system', 'taxonomy', 'user', 'watchdog',
    'devel', 'devel_node_access',
  );
}

function drupalorg_testing_profile_details() {
  return array(
    'name' => 'Drupal.org Testing',
    'description' => 'Install profile to setup a Drupal.org test for evaluating project module patches.',
  );
}

function drupalorg_testing_profile_final() {
  $types = array(
    array(
      'type' => 'page',
      'name' => st('Page'),
      'module' => 'node',
      'description' => st('If you want to add a static page, like a contact page or an about page, use a page.'),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
    ),
    array(
      'type' => 'story',
      'name' => st('Story'),
      'module' => 'node',
      'description' => st('Stories are articles in their simplest form: they have a title, a teaser and a body, but can be extended by other modules. The teaser is part of the body too. Stories may be used as a personal blog or for news articles.'),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
    ),
  );
  foreach ($types as $type) {
    $type = (object) _node_type_set_defaults($type);
    node_type_save($type);
  }

  // Default page to not be promoted and have comments disabled.
  variable_set('node_options_page', array('status'));
  variable_set('comment_page', COMMENT_NODE_READ_WRITE);

  // Don't display date and author information for page nodes by default.
  $theme_settings = variable_get('theme_settings', array());
  $theme_settings['toggle_node_info_page'] = FALSE;
  variable_set('theme_settings', $theme_settings);

  #1) configure devel.module
  variable_set('dev_query', 1);
  variable_set('devel_query_display', 1);
  variable_set('dev_timer', 1);
#  variable_set('devel_redirect_page', 1);
  variable_set('devel_error_handler', DEVEL_ERROR_HANDLER_BACKTRACE);
  // Save any old SMTP library
  if (variable_get('smtp_library', '') != '' && variable_get('smtp_library', '') != drupal_get_filename('module', 'devel')) {
    variable_set('devel_old_smtp_library', variable_get('smtp_library', ''));
  }
  variable_set('smtp_library', drupal_get_filename('module', 'devel'));

  #2) setup some standard roles for testing (non-uid-1 admin, content
  #admin, a role that only has "switch users" permission, etc), and
  #configure all perms appropriately.
  // extra roles
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(1, 'a', '%s', 'a@a.a', %d, 1)", md5('a'), time());
  user_authenticate('a', 'a');

  db_query("INSERT INTO {role} (rid, name) VALUES (3, 'admin user')");
  db_query("INSERT INTO {role} (rid, name) VALUES (4, 'content admin')");
  db_query("INSERT INTO {role} (rid, name) VALUES (5, 'switch user')");

  // Insert new role's permissions
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (3, 'administer blocks, use PHP for block visibility, access comments, administer comments, post comments, post comments without approval, access devel information, execute php code, devel_node_access module, view devel_node_access information, administer filters, administer menu, access content, administer content types, administer nodes, create page content, create story content, edit own page content, edit own story content, edit page content, edit story content, revert revisions, view revisions, access administration pages, administer site configuration, select different theme, administer taxonomy, access user profiles, administer access control, administer users, change own username', 0)");
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (4, 'administer blocks, access comments, administer comments, post comments, post comments without approval, administer menu, access content, administer nodes, create page content, create story content, edit own page content, edit own story content, edit page content, edit story content, revert revisions, view revisions, access user profiles, administer users', 0)");
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (5, 'switch users', 0)");

  #4) also create a bunch of random users with the generate script from
  #devel.module...
  include_once "generate-users.php";

  #3) create a small pool of users in each of the roles, all of which
  #are also in the "switch users" role, enable the switch users block
  #from devel.module, etc. [2]
  db_query("INSERT INTO {users_roles} VALUES (1, 3)");
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(51, 'admin1', '%s', 'admin1@a.a', %d, 1)", md5('a'), time());
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(52, 'admin2', '%s', 'admin2@a.a', %d, 1)", md5('a'), time());
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(53, 'content1', '%s', 'content1@a.a', %d, 1)", md5('a'), time());
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(54, 'content2', '%s', 'content2@a.a', %d, 1)", md5('a'), time());
  db_query("INSERT INTO {users_roles} VALUES (51, 3)");
  db_query("INSERT INTO {users_roles} VALUES (52, 3)");
  db_query("INSERT INTO {users_roles} VALUES (53, 4)");
  db_query("INSERT INTO {users_roles} VALUES (54, 4)");
  db_query("INSERT INTO {users_roles} VALUES (51, 5)");
  db_query("INSERT INTO {users_roles} VALUES (52, 5)");
  db_query("INSERT INTO {users_roles} VALUES (53, 5)");
  db_query("INSERT INTO {users_roles} VALUES (54, 5)");
  db_query("UPDATE {sequences} SET id = %d WHERE name = 'users_uid'", 54);

  db_query("UPDATE {blocks} SET status = 1, region = 'left' WHERE module='devel'");

  #5) create a bunch of test content with the generate script.
  include_once "generate-content.php";

  _block_rehash();
}
