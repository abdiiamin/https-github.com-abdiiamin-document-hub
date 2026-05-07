<?php
// public/index.php
require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../app/Core/App.php';

use App\Core\App;

// Initialize application
$app = new App();

// Define routes
$app->router->get('/', 'HomeController@index');
$app->router->get('/browse', 'DocumentController@browse');
$app->router->get('/document/{id}', 'DocumentController@show');
$app->router->get('/download/{id}', 'DownloadController@download');
$app->router->get('/pricing', 'PageController@pricing');
$app->router->get('/search', 'SearchController@search');

// Authentication routes
$app->router->get('/login', 'AuthController@loginForm');
$app->router->post('/login', 'AuthController@login');
$app->router->get('/register', 'AuthController@registerForm');
$app->router->post('/register', 'AuthController@register');

// Protected routes
$app->router->get('/dashboard', 'UserController@dashboard', ['auth']);
$app->router->get('/downloads', 'UserController@downloads', ['auth']);

// Run application
$app->run();


// public/index.php

/**
 * DocumentHub - Professional Document Download Platform
 * 
 * @package DocumentHub
 * @version 1.0.0
 */

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../storage/logs/error.log');

// Timezone
date_default_timezone_set('UTC');

// Start session if not started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Autoloader
require_once __DIR__ . '/../vendor/autoload.php';

// Load helper functions
require_once __DIR__ . '/../src/Helpers/functions.php';

// Initialize and run application
try {
    $app = \App\Core\App::getInstance();
    $app->run();
} catch (\Exception $e) {
    if ($_ENV['APP_DEBUG'] ?? false) {
        echo "<h1>Application Error</h1>";
        echo "<p><strong>Message:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
        echo "<p><strong>File:</strong> " . htmlspecialchars($e->getFile()) . "</p>";
        echo "<p><strong>Line:</strong> " . $e->getLine() . "</p>";
        echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
    } else {
        http_response_code(500);
        require __DIR__ . '/../views/errors/500.php';
    }
    
    error_log("Application Error: " . $e->getMessage());
}