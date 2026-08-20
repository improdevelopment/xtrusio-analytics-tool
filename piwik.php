<?php

/**
 * Xtrusio - analytics platform
 *
 * Backwards-compatible shim. The canonical tracker endpoint is xtrusio.php;
 * this file only exists so tracking snippets deployed before the rebrand keep
 * working. Safe to delete once no site references it.
 *
 * @license https://www.gnu.org/licenses/gpl-3.0.html GPL v3 or later
 */

if (!defined('PIWIK_DOCUMENT_ROOT')) {
    define('PIWIK_DOCUMENT_ROOT', dirname(__FILE__) == '/' ? '' : dirname(__FILE__));
}

require_once PIWIK_DOCUMENT_ROOT . '/xtrusio.php';
