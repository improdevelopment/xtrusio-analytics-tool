<?php

/**
 * Xtrusio - analytics platform
 *
 * Tracker endpoint. This file is the canonical tracker entry point; matomo.php
 * and piwik.php are kept as backwards-compatible shims that include piwik.php.
 */

if (!defined('PIWIK_DOCUMENT_ROOT')) {
    define('PIWIK_DOCUMENT_ROOT', dirname(__FILE__) == '/' ? '' : dirname(__FILE__));
}

include PIWIK_DOCUMENT_ROOT . '/piwik.php';
