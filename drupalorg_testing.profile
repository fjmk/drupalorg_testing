<?php

function drupalorg_testing_profile_modules() {
  return array(
    // core, required
    'block', 'filter', 'node', 'system', 'user', 'watchdog',
    // core, optional as per http://drupal.org/node/27367
    'aggregator', 'book', 'comment', 'contact', 'drupal', 'forum', 'help',
    'legacy', 'path', 'profile', 'menu', 'search', 'statistics',
    'taxonomy', 'throttle', 'tracker', 'upload',
    // contrib modules
    'codefilter', 'cvs', 'devel', 'project', 'project_issue', 'project_release',
  );
}

function drupalorg_testing_profile_details() {
  return array(
    'name' => 'Drupal.org Testing',
    'description' => 'Install profile to setup a Drupal.org test site suitable for evaluating project module patches.',
  );
}

function drupalorg_testing_profile_final() {
  // If not in 'safe mode', increase the maximum execution time:
  if (!ini_get('safe_mode')) {
    set_time_limit(0);
  }

  _drupalorg_testing_create_node_types();
  _drupalorg_testing_configure_theme();
  _drupalorg_testing_configure_devel_module();
  _drupalorg_testing_create_admin_and_login();
  _drupalorg_testing_create_roles();
  _drupalorg_testing_create_users();
  _drupalorg_testing_delete_old_content();
  _drupalorg_testing_create_content();
  _block_rehash();
}

function _drupalorg_testing_create_node_types() {
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
}

function _drupalorg_testing_configure_theme() {
  // Don't display date and author information for page nodes by default.
  $theme_settings = variable_get('theme_settings', array());
  $theme_settings['toggle_node_info_page'] = FALSE;
  variable_set('theme_settings', $theme_settings);
}

function _drupalorg_testing_configure_devel_module() {
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

  // enable the switch users block from devel.module, etc. [2]
  db_query("UPDATE {blocks} SET status = 1, region = 'left' WHERE module='devel'");
}

function _drupalorg_testing_create_admin_and_login() {
  // create the admin account
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(1, 'a', '%s', 'a@a.a', %d, 1)", md5('a'), time());
  user_authenticate('a', 'a');
}

function _drupalorg_testing_create_roles() {
  #2) setup some standard roles for testing (non-uid-1 admin, content
  #admin, a role that only has "switch users" permission, etc), and
  #configure all perms appropriately.
  // extra roles
  db_query("INSERT INTO {role} (rid, name) VALUES (3, 'admin user')");
  db_query("INSERT INTO {role} (rid, name) VALUES (4, 'content admin')");
  db_query("INSERT INTO {role} (rid, name) VALUES (5, 'switch user')");

  // Insert new role's permissions
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (3, 'administer blocks, use PHP for block visibility, access comments, administer comments, post comments, post comments without approval, access devel information, execute php code, devel_node_access module, view devel_node_access information, administer filters, administer menu, access content, administer content types, administer nodes, create page content, create story content, edit own page content, edit own story content, edit page content, edit story content, revert revisions, view revisions, access administration pages, administer site configuration, select different theme, administer taxonomy, access user profiles, administer access control, administer users, change own username', 0)");
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (4, 'administer blocks, access comments, administer comments, post comments, post comments without approval, administer menu, access content, administer nodes, create page content, create story content, edit own page content, edit own story content, edit page content, edit story content, revert revisions, view revisions, access user profiles, administer users', 0)");
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (5, 'switch users', 0)");
}

function _drupalorg_testing_create_users() {
  #4) also create a bunch of random users with the generate script from
  #devel.module...
  include_once "generate-users.php";
  // use one of your own domains. Using somebody else's domain is rude.
  make_users(50, 'example.com');

  #3) create a small pool of users in each of the roles, all of which
  #are also in the "switch users" role,
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
}

function _drupalorg_testing_delete_old_content() {
  db_query("DELETE FROM {comments}");
  db_query("DELETE FROM {node}");
  db_query("DELETE FROM {node_revisions}");
  db_query("DELETE FROM {node_comment_statistics}");
  if (db_table_exists(forum)) { db_query("DELETE FROM {forum}"); }
  db_query("DELETE FROM {url_alias}");
  db_query("UPDATE {sequences} SET id = '0' WHERE name = 'node_nid'");
  db_query("UPDATE {sequences} SET id = '0' WHERE name = 'comments_cid'");
  db_query("ALTER TABLE {node} AUTO_INCREMENT = 1");
  db_query("ALTER TABLE {comments} AUTO_INCREMENT = 1");
}

function _drupalorg_testing_create_content() {
  #5) create a bunch of test content with the generate script.
  include_once "generate-content.php";

  // create 100 pseudo-random nodes:
  $users = get_users();
  create_nodes(50, $users);

  $nodes = get_nodes();
  $terms = get_terms();
  add_terms($nodes, $terms);

  $comments = get_comments();
  create_comments(200, $users, $nodes, $comments);
}
