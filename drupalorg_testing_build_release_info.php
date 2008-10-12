<?php
// $Id$

/**
 * @file
 *
 * This file uses the XML data from updates.drupal.org and parses
 * those feeds to create the drupalorg_testing_release_info.inc file.
 *
 * This file is intended to be used from the command line and will
 * not be called in the presence of a bootstrapped instance of drupal.
 *
 * The assumed workflow is that periodically someone will run this
 * file from the command line and then provide a patch of the
 * drupalorg_testing_release_info.inc file to the Drupal.org testing
 * profile project at http://drupal.org/project/drupalorg_testing
 *
 * Alternately, if a user wants to create a test installation site
 * with the most recent releases data, he can manually run
 * this file himself, as doing so will update the
 * drupalorg_testing_release_info.inc file.
 *
 *  *** THIS SCRIPT REQUIRES PHP 5 OR ABOVE ***
 */

// Ensure that the SimpleXML PHP extension is enabled.  It is only available
// in PHP 5 or greater but is enabled by default.
if (!phpversion('SimpleXML')) {
  exit(wordwrap("PHP 5 or greater is required to use this script.  The SimpleXML extension must also be enabled.  See http://us2.php.net/manual/en/book.simplexml.php for more information.\n"));
}

// URL to check updates at.  This value should probably be the same
// as the UPDATE_STATUS_DEFAULT_URL in the update_status module on
// drupal.org.
define('BASE_URL', 'http://updates.drupal.org/release-history');

// An array of all project uris included in the drupalorg_testing
// profile for which releases should be created.
// NOTE:  This array needs to be manually modified if a project
// is added to the Drupal.org testing profile.
$projects = array(
  'drupal', 'drupalorg_testing', 'phptal', 'zen', 'af',
  'project', 'project_issue', 'cvslog', 'subscribe', 'user_status',
);

// An array of all API compatability version taxonomy terms
// (as used on drupal.org) to create releases for.
// NOTE:  When a new major version of Drupal is released,
// this array should be manually modified.
$api_terms = array('4.7.x', '5.x', '6.x');

$releases = array();
$supported_releases = array();

foreach ($projects as $project) {
  foreach ($api_terms as $api_term) {
    dot_get_releases($project, $api_term, $releases, $supported_releases);
  }
}

// Build the string of text that will actually be written to the file.
$output = get_file_header();
$output .= "\n\n/**\n * Array of information about releases.\n */\n";
$output .= "\$releases = " . var_export($releases, TRUE) . ";\n";
$output .= "\n\n/**\n * Array of information about supported branches.\n */\n";
$output .= "\$supported_releases = " . var_export($supported_releases, TRUE) . ";\n";
$output .= "// End of file.";

// Write the drupalorg_testing_release_info.inc file.
$testing_releases = fopen('drupalorg_testing_release_info.inc', "w");
fwrite($testing_releases, $output);
fclose($testing_releases);

/**
 * Retrieves the XML of releases for a given project
 * and API compatability term and returns an array of
 * releases.
 *
 * @param $project
 *   The uri (project short name) of the project to get releases for.
 * @param $api_term
 *   The API compatability term to find releases for.  eg. '4.7.x' or '5.x'.
 * @param $releases
 *   An array containing information about each release of all projects.
 * @param $supported_releases
 *   A nested array containing information about supported versions of
 *   each release series for each project.
 *
 * @return
 *   Nothing.  The data is added to the $releases and $supported_releases
 *   arrays which are passed in by reference.
 */
function dot_get_releases($project, $api_term, &$releases, &$supported_releases) {
  // Get the XML for the given project and API term pair.
  $url = BASE_URL ."/$project/$api_term";
  $xmlstr = file_get_contents($url);
  if (!empty($xmlstr)) {
    $xml = new SimpleXMLElement($xmlstr);
    if (!empty($xml->releases->release)) {
      foreach ($xml->releases->release as $key => $value) {
        $parsed_file_url = parse_url((string) $value->download_link);
        $releases[] = array(
          'title' => (string) $value->name,
          'version' => (string) $value->version,
          'project_uri' => $project,
          'major' => (int) $value->version_major,
          'patch' => (int) $value->version_patch,
          'extra' => (string) $value->version_extra,
          'categories' => get_categories($api_term, $value->terms),
          'tag' => (string) $value->tag,
          'rebuild' => (string) $value->version_extra == 'dev' ? 1 : 0,
          'file_name' => isset($parsed_file_url['path']) ? pathinfo($parsed_file_url['path'], PATHINFO_BASENAME) : '',
          'file_hash' => (string) $value->mdhash,
          'file_date' => (int) $value->date,
          'status' => (string) $value->status == 'published' ? 1 : 0,
        );
      }
    }

    // Store supported versions information
    $properties = array('project_status', 'recommended_major', 'supported_majors', 'default_major');
    foreach ($properties as $property) {
      $supported_releases[$project][$api_term][$property] = isset($xml->$property) ? (string) $xml->$property : NULL;
    }
  }
}

/**
 * Build an array with all categories assigned to the release.
 *
 * @param $api_term
 *   The text value of the API term associated with the release.
 * @param $terms
 *   A SimpleXML object representing the terms attribute of the release.
 *
 * @return
 *   An array with the text values of all terms associated with the release.
 */
function get_categories($api_term, $terms) {
  $all_terms = array();

  // The API term does not come as part of $terms, so add that separately.
  $all_terms[] = $api_term;

  // Because $terms is a SimpleXML object containing SimpleXML objects
  // it's necessary to cast it and its children parts to an array
  // to handle them.
  $terms = (array)$terms;
  if (isset($terms['term'])) {
    $terms = (array)$terms['term'];
    foreach ($terms as $key => $value) {
      if (is_numeric($key)) {
        $value = (array)$value;
          $all_terms[] = $value['value'];
      }
      elseif ($key == 'value') {
        if (!empty($value)) {
          $all_terms[] = $value;
        }
      }
    }
  }
  return $all_terms;
}

/**
 * Returns the text that goes at the top of drupalorg_testing_release_info.inc.
 */
function get_file_header() {
  $output = "<?php\n";
  $output .= '// $Id$'."\n\n";
  $output .= '// Generated with: '. basename(__FILE__) ."\n";
  $output .= '// Generated on: '. date('r') ."\n\n";
  $file_phpdoc = <<<EOF
/**
 * @file
 *
 * This file defines two arrays of information about project release nodes
 * that should be created.
 *
 * This file is separate from the rest of the drupalorg_testing profile so
 * that it can be easily regenerated by a script that uses the XML feed from
 * updates.drupal.org to get actual data about project releases from
 * drupal.org.
 */

EOF;
  $output .= $file_phpdoc;
  return $output;
}
