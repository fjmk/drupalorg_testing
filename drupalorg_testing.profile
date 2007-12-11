<?php

// $Id$

/**
 * @file
 * Installation profile that configures a site to mimic drupal.org,
 * especially the project management and issue tracking functionality,
 * to facilitate testing. More information can be found in the
 * README.txt file.
 *
 * Some of the constants at the top of this file can be changed to
 * customize the profile for your site (names, passwords, domains, etc).
 */

//----------------------------------------
// Settings you probably want to customize
//----------------------------------------

/// The initial password for all of the well-known users created.
define('D_O_PASSWORD', 'a');

/// Name to be used for the user 1 (full admin) account.
define('D_O_USER1', 'a');

/// Domain to use for all user e-mail addresses.
define('D_O_DOMAIN', 'example.com');


//----------------------------------------
// Settings you might want to customize
//----------------------------------------

/// E-mail address to use for the site itself.
define('D_O_SITE_MAIL', D_O_USER1 .'@'. D_O_DOMAIN);

/// Number of users per role the profile will create.
define('D_O_NUM_USERS_PER_ROLE', 2);

/**
 * Number of users per role the profile will create CVS accounts for.
 *
 * By default, each role gets 2 users (e.g. "auth1" and "auth2"), but
 * only one of them gets a CVS account (e.g. "auth1"). This is useful
 * for testing to see how things on the site behave for people in
 * various roles with and without CVS accounts.
 */
define('D_O_NUM_CVS_USERS_PER_ROLE', 1);


//----------------------------------------
// Settings you should not change
//----------------------------------------

define('D_O_ROLE_ANONYMOUS', 1);
define('D_O_ROLE_AUTHENTICATED', 2);
define('D_O_ROLE_ADMINISTRATOR', 3);
define('D_O_ROLE_SITE_MAINTAINER', 4);
define('D_O_ROLE_DOC_MAINTAINER', 5);
define('D_O_ROLE_CVS_ADMIN', 6);
define('D_O_ROLE_SWITCH', 7);


//----------------------------------------
// Profile code
//----------------------------------------

function drupalorg_testing_profile_modules() {
  return array(
    // core, required
    'block', 'filter', 'node', 'system', 'user', 'watchdog',
    // core, optional as per http://drupal.org/node/27367
    'aggregator', 'book', 'comment', 'contact', 'drupal', 'forum', 'help',
    'legacy', 'path', 'profile', 'menu', 'search', 'statistics',
    'taxonomy', 'tracker', 'upload',
    // contrib modules
    'codefilter', 'cvs', 'devel', 'project', 'project_issue', 'project_release',
    'comment_upload',
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

  variable_set('site_mail', D_O_SITE_MAIL);
  _drupalorg_testing_create_node_types();
  _drupalorg_testing_configure_theme();
  _drupalorg_testing_configure_devel_module();
  _drupalorg_testing_configure_cvs_module();
  _drupalorg_testing_create_admin_and_login();
  _drupalorg_testing_create_roles();
  _drupalorg_testing_create_users();
  _drupalorg_testing_create_project_terms();
  _drupalorg_testing_create_content();
  _drupalorg_testing_configure_project_settings();
  _drupalorg_testing_create_issues();
  _drupalorg_testing_create_menus();
  _drupalorg_testing_configure_blocks();
  _block_rehash();
  menu_rebuild();
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
}

function _drupalorg_testing_configure_cvs_module() {
  $repos = array(t('Drupal'), t('Contributions'));
  foreach ($repos as $repo_name) {
    $repo = array(
      'name' => $repo_name,
      'method' => 1,  // external
      'op' => t('Save repository'),
    );
    drupal_execute('cvs_repository_form', $repo);
  }

  // Set the branch/tag release messages to match drupal.org.
  variable_set('cvs_message_new_release_branch', t('Your development snapshot release has been added. However, a downloadable package will not be available and this release will not be published until the packaging scripts run again. These scripts only make new development snapshot releases every 12 hours, so please be patient.'));
  variable_set('cvs_message_new_release_tag', t('Your official release has been added. A downloadable package will not be available and this release will not be published until the packaging scripts run again. These scripts run every 5 minutes for official releases, so it should be available soon. Once it has been published, this release will be available in the list of choices for the "Default version" selector on your project\'s edit tab.'));
}

function _drupalorg_testing_create_admin_and_login() {
  // create the admin account
  // Shouldn't we be using user_save() here?
  db_query("INSERT INTO {users} (uid, name, pass, mail, created, status) VALUES(1, '%s', '%s', '%s', %d, 1)", D_O_USER1, md5(D_O_PASSWORD), D_O_USER1 .'@'. D_O_DOMAIN, time());
  // Initialize the record in the {sequences} table.
  db_next_id('{users}_uid');
  user_authenticate(D_O_USER1, D_O_PASSWORD);
  // Create a CVS account, too.
  db_query("INSERT INTO {cvs_accounts} (uid, cvs_user, pass, motivation, status) VALUES (%d, '%s', '%s', '%s', %d)", 1, D_O_USER1, crypt(D_O_PASSWORD), '', CVS_APPROVED);
}

/**
 * Setup roles and permissions to mimic drupal.org.
 * This creates an additional role, "user switcher", that has the
 * "swtich user" permission from the devel.module.
 */
function _drupalorg_testing_create_roles() {
  // Map role names to role ID constants.
  $roles = array(
    D_O_ROLE_ANONYMOUS => 'anonymous',
    D_O_ROLE_AUTHENTICATED => 'authenticated',
    D_O_ROLE_ADMINISTRATOR => 'administrator',
    D_O_ROLE_DOC_MAINTAINER => 'documentation maintainer',
    D_O_ROLE_SITE_MAINTAINER => 'site maintainer',
    D_O_ROLE_CVS_ADMIN => 'CVS administrator',
    D_O_ROLE_SWITCH => 'user switcher',
  );

  // Define permissions for each role ID.
  $permissions = array(
    D_O_ROLE_ADMINISTRATOR => array(
      // aggregator
      'access news feeds',
      'administer news feeds',
      // block
      'administer blocks',
       //'use PHP for block visibility',
      // book
      'create book pages',
      'create new books',
      'edit book pages',
      'edit own book pages',
      'outline posts in books',
      'see printer-friendly version',
      // comment
      'access comments',
      'administer comments',
      'post comments',
      'post comments without approval',
      // contact
      'access site-wide contact form',
      // cvs
      'access CVS messages',
      'administer CVS',
      // devel
      'access devel information',
      'execute php code',
      'devel_node_access module',
      'view devel_node_access information',
      // filter
      'administer filters',
      'administer forums',
      // forum
      'create forum topics',
      'edit own forum topics',
      // menu
      'administer menu',
      // node
      'access content',
      'administer content types',
      'administer nodes',
      'create page content',
      'create story content',
      'edit own page content',
      'edit own story content',
      'edit page content',
      'edit story content',
      'revert revisions',
      'view revisions',
      // path
      'administer url aliases',
      'create url aliases',
      // poll
       //'cancel own vote',
      'create polls',
       //'inspect all votes',
      'vote on polls',
      // project
      'access own projects',
      'access projects',
      'administer projects',
      'maintain projects',
      // project_issue
      'access own project issues',
      'access project issues',
      'create project issues',
      //'edit own project issues',
      'set issue status active',
      'set issue status active (needs more info)',
      'set issue status by design',
      'set issue status closed',
      'set issue status duplicate',
      'set issue status fixed',
      'set issue status patch (code needs review)',
      'set issue status patch (code needs work)',
      'set issue status patch (ready to be committed)',
      'set issue status postponed',
      'set issue status wont fix',
      // search
      'administer search',
      'search content',
      'use advanced search',
      // system
      'access administration pages',
      'administer site configuration',
       //'select different theme',
      // taxonomy
      'administer taxonomy',
      // upload
      'upload files',
      'view uploaded files',
      // user
      'access user profiles',
      'administer access control',
      'administer users',
      'change own username',
    ),
    D_O_ROLE_SITE_MAINTAINER => array(
      // aggregator
      'administer news feeds',
      // book
      'create new books',
      'edit book pages',
      'outline posts in books',
      // comment
      'administer comments',
      // forum
      'edit own forum topics',
      // node
      'administer nodes',
      'revert revisions',
      'view revisions',
      // system
      'access administration pages',
      // upload
      'upload files',
    ),
    D_O_ROLE_DOC_MAINTAINER => array(
      // book
      'create book pages',
      'edit book pages',
      'edit own book pages',
      // node
      'view revisions',
    ),
    D_O_ROLE_CVS_ADMIN => array(
      // cvs
      'administer CVS',
      // project
      'administer projects',
      // system
      'access administration pages',
    ),
    D_O_ROLE_SWITCH => array(
      // devel
      'switch users',
      'access devel information',
    ),
    D_O_ROLE_AUTHENTICATED => array(
      // aggregator
      'access news feeds',
      // book
      'create book pages',
      'edit own book pages',
      'see printer-friendly version',
      // comment
      'access comments',
      'post comments',
      'post comments without approval',
      // contact
      'access site-wide contact form',
      // cvs
      'access CVS messages',
      // forum
      'create forum topics',
      // node
      'access content',
      // poll
      'vote on polls',
      // project
      'access projects',
      'maintain projects',
      // project_issue
      'access project issues',
      'create project issues',
      'set issue status active',
      'set issue status active (needs more info)',
      'set issue status by design',
      'set issue status closed',
      'set issue status duplicate',
      'set issue status fixed',
      'set issue status patch (code needs review)',
      'set issue status patch (code needs work)',
      'set issue status patch (ready to be committed)',
      'set issue status postponed',
      'set issue status wont fix',
      // search
      'search content',
      'use advanced search',
      // upload
      'view uploaded files',
      // user
      'access user profiles',
      'change own username',
    ),
    D_O_ROLE_ANONYMOUS => array(
      // aggregator
      'access news feeds',
      // comment
      'access comments',
      // contact
      'access site-wide contact form',
      // cvs
      'access CVS messages',
      // node
      'access content',
      // project
      'access projects',
      // project_issue
      'access project issues',
      // search
      'search content',
      // upload
      'view uploaded files',
      // user
      'access user profiles',
    ),
  );

  // Delete current roles and permissions and re-populate them.
  db_query('TRUNCATE {role}');
  db_query('TRUNCATE {permission}');

  foreach ($roles as $rid => $name) {
    db_query("INSERT INTO {role} (rid, name) VALUES (%d, '%s')", $rid, $name);
  }
  foreach ($permissions as $rid => $perms) {
    db_query("INSERT INTO {permission} (rid, perm, tid) VALUES (%d, '%s', 0)", $rid, implode(', ', $perms));
  }
}

function _drupalorg_testing_create_users() {
  // Define some well-known users in each of the roles.  All of these will
  // have the same password (see D_O_PASSWORD at the top of this file), and
  // will also belong to the 'User switchers' role to be able to easily switch
  // between them.
  $users = array(
    'admin' => array(D_O_ROLE_ADMINISTRATOR),
    'site' => array(D_O_ROLE_SITE_MAINTAINER),
    'doc' => array(D_O_ROLE_DOC_MAINTAINER),
    'cvs' => array(D_O_ROLE_CVS_ADMIN),
    'auth' => array(), // no extra roles
  );

  // Create a dummy user object for user_save().
  $account = new stdClass();
  $account->uid = 0;

  // Now, generate our well-known users.
  foreach ($users as $name => $roles) {
    $edit = array();

    // All the well-known users have the same password.
    $edit['pass'] = D_O_PASSWORD;
    $edit['status'] = 1;

    // Put all of these custom users into the 'User switchers' role, too.
    // We have to flip the roles array here, because that's what user_save() is expecting.
    $edit['roles'] = array_flip(array_merge(array(D_O_ROLE_SWITCH), $roles));

    for ($i = 1; $i <= D_O_NUM_USERS_PER_ROLE; $i++) {
      $edit['name'] = $name . $i;
      $edit['mail'] = $edit['name'] .'@'. D_O_DOMAIN;
      user_save($account, $edit);
    }
    for ($i = 1; $i <= D_O_NUM_CVS_USERS_PER_ROLE; $i++) {
      $user_name = $name . $i;
      $user = user_load(array('name' => $user_name));
      db_query("INSERT INTO {cvs_accounts} (uid, cvs_user, pass, motivation, status) VALUES (%d, '%s', '%s', '%s', %d)", $user->uid, $user_name, crypt(D_O_PASSWORD), '', CVS_APPROVED);
    }
  }

  // Create 50 random users.
  require_once(drupal_get_path('module', 'devel') .'/devel_generate.inc');
  devel_create_users(50, FALSE);
}

/**
 * Auto-generates project-related terms from drupal.org.
 */
function _drupalorg_testing_create_project_terms() {
  // Add top-level project terms.
  $vid = _project_get_vid();
  $terms = array(
    t('Drupal project') => t('Get started by downloading the official Drupal core files. These official releases come bundled with a variety of modules and themes to give you a good starting point to help build your site. Drupal core includes basic community features like blogging, forums, and contact forms, and can be easily extended by downloading other contributed modules and themes.'),
    t('Installation profiles') => t('Installation profiles are a feature in Drupal core that was added in the 5.x series. The new Drupal installer allows you to specify an installation profile which defines which modules should be enabled, and can customize the new installation after they have been installed. This will allow customized "distributions" that enable and configure a set of modules that work together for a specific kind of site (Drupal for bloggers, Drupal for musicians, Drupal for developers, and so on).'),
    t('Modules') => t('Modules are plugins for Drupal that extend its core functionality. Only use matching versions of modules with Drupal. Modules released for Drupal 4.7.x will not work for Drupal 5.x. These contributed modules are not part of any official release and may not be optimized or work correctly.'),
    t('Theme engines') => t('Theme engines control how certain themes interact with Drupal. Most users will want to stick with the default included with Drupal core. These contributed theme engines are not part of any official release and may not work correctly. Only use matching versions of theme engines with Drupal. Theme engines released for Drupal 4.7.x will not work for Drupal 5.x.'),
    t('Themes') => t('Themes allow you to change the look and feel of your Drupal site. These contributed themes are not part of any official release and may not work correctly. Only use matching versions of themes with Drupal. Themes released for Drupal 4.7.x will not work for Drupal 5.x.'),
    t('Translations') => t('Drupal uses English by default, but may be translated to many other languages. To install these translations, unzip them and import the .po file through Drupal\'s administration interface for localization. You will need to turn on the locale module if it\'s not already enabled. You can check the completeness of translations on the translations <a href="/translation-status">status page</a>.'),
  );
  foreach ($terms as $name => $description) {
    drupal_execute('taxonomy_form_term', array('name' => $name, 'description' => $description), $vid);
  }

  // Add module categories.
  $parent = db_result(db_query("SELECT tid FROM {term_data} WHERE name = '%s'", t('Modules')));
  $terms = array(
    t('3rd party integration'),
    t('Administration'),
    t('CCK'),
    t('Commerce / advertising'),
    t('Community'),
    t('Content'),
    t('Content display'),
    t('Developer'),
    t('Evaluation/rating'),
    t('Event'),
    t('File management'),
    t('Filters/editors'),
    t('Import/export'),
    t('Location'),
    t('Mail'),
    t('Media'),
    t('Multilingual'),
    t('Organic Groups'),
    t('Paging'),
    t('Security'),
    t('Syndication'),
    t('Taxonomy'),
    t('Theme related'),
    t('User access/authentication'),
    t('User management'),
    t('Utility'),
    t('Views'),
  );
  foreach ($terms as $name) {
    drupal_execute('taxonomy_form_term', array('name' => $name, 'parent' => $parent), $vid);
  }

  // Add release versions.
  $vid = _project_release_get_api_vid();
  $terms = array(
    '6.x', '5.x', '4.7.x', '4.6.x', '4.5.x', '4.4.x',
    '4.3.x', '4.2.x', '4.1.x', '4.0.x',
  );
  foreach ($terms as $name) {
    drupal_execute('taxonomy_form_term', array('name' => $name), $vid);
  }

  // Add release types.
  $vocab = array(
    'name' => t('Release type'),
    'nodes' => array('project_release' => 'project_release'),
  );
  drupal_execute('taxonomy_form_vocabulary', $vocab);
  $vid = db_result(db_query("SELECT vid FROM {vocabulary} WHERE name = '%s'", t('Release type')));
  $terms = array(
    t('Security update'),
    t('Bug fixes'),
    t('New features'),
  );
  foreach ($terms as $name) {
    drupal_execute('taxonomy_form_term', array('name' => $name), $vid);
  }
}

function _drupalorg_testing_create_content() {
  // #5) Create a bunch of test content with the devel generate script.
  require_once(drupal_get_path('module', 'devel') .'/devel_generate.inc');

  // Create 100 pseudo-random nodes, and 200 pseudo-random comments.
  devel_generate_content(100, 200, 8, TRUE, array('page', 'story', 'forum'));

  _drupalorg_testing_create_content_project();
}

/**
 * Configures variables for project* modules.
 */
function _drupalorg_testing_configure_project_settings() {
  variable_set('project_sort_method', 'category');

  $types = array(
    t('Drupal Project') => array('name'),
    t('Installation profiles') => array('name', 'date'),
    t('Modules') => array('name', 'date', 'category'),
    t('Theme engines') => array('name'),
    t('Themes') => array('name', 'date'),
    t('Translations') => array('name'),
  );
  foreach ($types as $type => $settings) {
    $tid = _drupalorg_testing_get_tid_by_term($type);
    variable_set("project_sort_method_used_$tid", drupal_map_assoc($settings));
  }

  // Settings for project_release.module.
  variable_set('project_release_default_version_format', '!api#major%patch#extra');
  variable_set('project_release_overview', '-1');

  $active_tids = array();
  $active_terms = array('6.x', '5.x', '4.7.x');
  foreach ($active_terms as $term) {
    $tid = _drupalorg_testing_get_tid_by_term($term);
    $active_tids[$tid] = $tid;
  }
  variable_set('project_release_active_compatibility_tids', $active_tids);

  // Settings for project_issue.module.

  // Add the new, custom status values on d.o.
  $issue_status_new = array();
  $issue_status_new['status_add'] = array(
    'name' => t('patch (to be ported)'),
    'weight' => -4,
    'author_has' => 0,
    'default_query' => 1,
  );
  drupal_execute('project_issue_admin_states_form', $issue_status_new);

  $issue_status_new = array();
  $issue_status_new['status_add'] = array(
    'name' => t('active (needs more info)'),
    'weight' => -10,
    'author_has' => 0,
    'default_query' => 0,
  );
  drupal_execute('project_issue_admin_states_form', $issue_status_new);

  // Now, update the default status values for d.o customizations.
  $issue_status_updates = array();
  $issue_status_updates['status'] = array();
  $issue_status_updates['status'][8] = array(
    'name' => t('patch (code needs review)'),
    'weight' => -8,
    'author_has' => 0,
    'default_query' => 1,
  );
  $issue_status_updates['status'][13] = array(
    'name' => t('patch (code needs work)'),
    'weight' => -7,
    'author_has' => 0,
    'default_query' => 1,
  );
  $issue_status_updates['status'][14] = array(
    'name' => t('patch (ready to be committed)'),
    'weight' => -6,
    'author_has' => 0,
    'default_query' => 1,
  );
  // For some reason, the "default_query" is getting cleared if we don't
  // include it here again. :(  TODO: Figure out what's going on here.
  $issue_status_updates['status'][15] = array(
    'name' => t('patch (to be ported)'),
    'weight' => -4,
    'author_has' => 0,
    'default_query' => 1,
  );
  drupal_execute('project_issue_admin_states_form', $issue_status_updates);
}

/**
 * Generates sample issues.
 */
function _drupalorg_testing_create_issues() {
  $file = drupal_get_path('module', 'project_issue_generate') .'/project_issue_generate.inc';
  if (file_exists($file)) {
    require_once($file);
    project_issue_generate_issues(50);
  }
}

/**
 * Generates sample project content.
 */
function _drupalorg_testing_create_content_project() {
  // First, add one of each type of project.
  $values[t('Drupal project')] = array(
    'title' => t('Drupal'),
    'body' => t('Drupal is an open-source platform and content management system for building dynamic web sites offering a broad range of features and services including user administration, publishing workflow, discussion capabilities, news aggregation, metadata functionalities using controlled vocabularies and XML publishing for content sharing purposes. Equipped with a powerful blend of features and configurability, Drupal can support a diverse range of web projects ranging from personal weblogs to large community-driven sites.'),
    'uri' => 'drupal',
    'name' => D_O_USER1,
    'cvs_repository' => 1,
    'cvs_directory' => '/',
  );
  $values[t('Installation profiles')] = array(
    'title' => t('Drupal.org Testing'),
    'body' => t('This profile installs a site with the structure, content, permissions, etc of Drupal.org to facilitate the reproduction of bugs and testing of patches for the project modules.'),
    'uri' => 'drupalorg_testing',
    'name' => 'site1',
    'cvs_repository' => 2,
    'cvs_directory' => '/profiles/drupalorg_testing/',
  );
  $values[t('Theme engines')] = array(
    'title' => t('PHPTAL theme engine'),
    'body' => t('This is a theme engine for Drupal 5.x, which allows the use of templates written in the PHPTAL language. This engine does most of its work by calls to the <a href="/node/11810">PHPtemplate engine</a>, just replacing the underlying template engine with the one from phptal.sourceforge.net.'),
    'uri' => 'phptal',
    'name' => 'auth1',
    'cvs_repository' => 2,
    'cvs_directory' => '/theme-engines/phptal/',
  );
  $values[t('Themes')] = array(
    'title' => t('Zen'),
    'body' => t('Zen is the ultimate <em>starting theme</em> for Drupal 5. If you are building your own standards-compliant theme, you will find it much easier to start with Zen than to start with Garland or Bluemarine. This theme has LOTs of documentation in the form of code comments for both the PHP (template.php) and HTML (page.tpl.php, node.tpl.php).'),
    'uri' => 'zen',
    'name' => 'doc1',
    'cvs_repository' => 2,
    'cvs_directory' => '/themes/zen/',
  );
  $values[t('Translations')] = array(
    'title' => t('Afrikaans Translation'),
    'body' => t("This page is the official translation of Drupal core into Afrikaans. This translation is currently available for Drupal 4.6's and Drupal 4.7's (cvs) core. Modules are being added as we progress with the translation effort."),
    'uri' => 'af',
    'name' => 'auth1',
    'cvs_repository' => 2,
    'cvs_directory' => '/translations/af/',
  );
  foreach ($values as $category => $project) {
    $project['project_type'] = _drupalorg_testing_get_tid_by_term($category);
    $project['mail'] = variable_get('site_mail', D_O_SITE_MAIL);
    drupal_execute('project_project_node_form', $project, array('type' => 'project_project'));

    // CHEESY HACK: Because Drupal is not fully bootstrapped at install time,
    // we have to do raw DB manipulation to add the terms. Sigh...
    $node = node_load(array('title' => $project['title']));
    db_query('INSERT INTO {term_node} (nid, tid) VALUES (%d, %d)', $node->nid, $project['project_type']);
  }

  // Modules... let's start with some developer modules so we have a few in
  // the same category.
  $values = array();
  $values[] = array(
    'title' => t('Project'),
    'body' => t('This module provides project management for Drupal sites.  Projects are generally assumed to represent software that has source code, releases, and so on.  This module provides advanced functionality for browsing projects, optionally classifying them with a special taxonomy, and managing downloads of different versions of the software represented by the projects.  It is used to provide the <a href="/project">downloads pages</a> for Drupal.org.'),
    'uri' => 'project',
    'categories' => array(t('Developer')),
    'name' => 'site1',
    'cvs_repository' => 2,
    'cvs_directory' => '/modules/project/',
  );
  $values[] = array(
    'title' => t('Project issue tracking'),
    'body' => t('This module provides issue tracking for projects created with the <a href="/project/project">project module</a>.  <!--break-->It allows users to submit issues (bug reports, feature requests, tasks, etc) and enables teams to track their progress.  It provides e-mail notifications to members about updates to items.  Similar to many issue tracking systems.  You can see it in action at <a href="/project/issues">http://drupal.org/project/issues</a>.'),
    'uri' => 'project_issue',
    'categories' => array(t('Developer')),
    'name' => 'site1',
    'cvs_repository' => 2,
    'cvs_directory' => '/modules/project_issue/',
  );
  $values[] = array(
    'title' => t('CVS integration'),
    'body' => t('A module that lets you track CVS commit messages. You can see it in action at http://drupal.org/cvs/. Interfaces with the project module to make releases via specific CVS branches and tags, and provides per-project source code access control.'),
    'uri' => 'cvslog',
    'categories' => array(t('Developer')),
    'name' => 'cvs1',
    'cvs_repository' => 2,
    'cvs_directory' => '/modules/cvslog/',
  );
  // Subscribe module, because its menu path and project/subscribe hate
  // each other. ;)
  $values[] = array(
    'title' => t('Subscribe'),
    'body' => t('The subscribe module allows you to subscribe to channels which other Drupal sites publish using the publish module. Both push and pull publishing models are supported. Communication between the publishing and subscribing sites is accomplished via XML-RPC.

This module is under development but testing and feedback are welcome.'),
    'uri' => 'subscribe',
    'categories' => array(t('Content')),
    'name' => 'doc1',
    'cvs_repository' => 2,
    'cvs_directory' => '/modules/subscribe/',
  );
  // User status module, because it's in more than one category.
  $values[] = array(
    'title' => t('User status change notifications'),
    'body' => t('This module enables sites to automatically send customized email notifications on the following events:
<ul>
<li>account activated</li>
<li>account blocked</li>
<li>account deleted</li>
</ul>
The first case is especially useful for sites that are configured to require administrator approval for new account requests.'),
    'uri' => 'user_status',
    'categories' => array(t('Administration'), t('Mail'), t('User management')),
    'name' => 'admin1',
    'cvs_repository' => 2,
    'cvs_directory' => '/modules/user_status/',
  );

  $modules_tid = _drupalorg_testing_get_tid_by_term(t('Modules'));
  foreach ($values as $project) {
    $project['project_type'] = $modules_tid;
    $categories = array();
    foreach ($project['categories'] as $category) {
      $categories[] = _drupalorg_testing_get_tid_by_term($category);
    }
    $project["tid_$modules_tid"] = drupal_map_assoc($categories);
    $project['mail'] = variable_get('site_mail', D_O_SITE_MAIL);
    drupal_execute('project_project_node_form', $project, array('type' => 'project_project'));

    // CHEESY HACK: Because Drupal is not fully bootstrapped at install time,
    // we have to do raw DB manipulation to add the terms. Sigh...
    $node = node_load(array('title' => $project['title']));
    db_query('INSERT INTO {term_node} (nid, tid) VALUES (%d, %d)', $node->nid, $project['project_type']);
    foreach ($categories as $category) {
      db_query('INSERT INTO {term_node} (nid, tid) VALUES (%d, %d)', $node->nid, $category);
    }
  }
}

/**
 * Setup menus to match drupal.org.
 */
function _drupalorg_testing_create_menus() {
  // Setup primary links.
  $pid = variable_get('menu_primary_menu', 0);
  $items['book'] = array(
    'path' => 'book',
    'title' => t('Handbooks'),
    'weight' => 0,
  );
  $items['forum'] = array(
    'path' => 'forum',
    'title' => t('Forum'),
    'weight' => 2,
  );
  $items['project'] = array(
    'path' => 'project',
    'title' => t('Downloads'),
    'weight' => 4,
  );
  $items['contact'] = array(
    'path' => 'contact',
    'title' => t('Contact'),
    'weight' => 6,
  );

  foreach ($items as $item) {
    $item['pid'] = $pid;
    $item['type'] = MENU_CUSTOM_ITEM | MENU_MODIFIED_BY_ADMIN;
    $item['description'] = '';
    menu_save_item($item);
  }
}

function _drupalorg_testing_configure_blocks() {
  // Each entry should be an array with: (module, delta, region, weight)
  $blocks = array();

  // User login
  $blocks[] = array('user', 0, 'right', -4);
  // Primary navigation
  $blocks[] = array('user', 1, 'right', -2);
  // Devel tools
  $blocks[] = array('devel', 1, 'right', 0);
  // Switch users
  $blocks[] = array('devel', 0, 'right', 2);
  // New forum topics
  $blocks[] = array('forum', 1, 'right', 4);

  foreach ($blocks as $block) {
    db_query("DELETE FROM {blocks} WHERE module = '%s' AND delta = %d", $block[0], $block[1]);
    db_query("INSERT INTO {blocks} (module, delta, theme, status, region, weight, pages) VALUES ('%s', %d, '%s', %d, '%s', %d, '')", $block[0], $block[1], 'garland', 1, $block[2], $block[3]);
  }
}

/**
 * Helper function; get a term's ID.
 */
function _drupalorg_testing_get_tid_by_term($term) {
  $terms = taxonomy_get_term_by_name($term);
  return $terms[0]->tid;
}
