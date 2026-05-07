// test_db.php (place in project root)
<?php
require_once 'vendor/autoload.php';

$app = \App\Core\App::getInstance();

try {
    $result = $app->db->fetch("SELECT 1 as test");
    echo "✅ Database connection successful!";
} catch (\Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage();
}