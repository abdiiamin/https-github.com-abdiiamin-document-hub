<?php
// setup.php - Simple PHP Setup Script
echo "<h1>DocumentHub Setup</h1>";

// 1. Create directories
$dirs = [
    'storage/documents/2024',
    'storage/thumbnails',
    'storage/logs',
    'storage/cache',
    'storage/backups',
    'storage/temp',
    'public/uploads'
];

foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0777, true);
        echo "<p style='color:green'>✅ Created: $dir</p>";
    } else {
        echo "<p style='color:blue'>ℹ️ Exists: $dir</p>";
    }
}

// 2. Create .env if not exists
if (!file_exists('.env')) {
    copy('.env.example', '.env');
    echo "<p style='color:green'>✅ Created .env file</p>";
}

// 3. Test database connection
try {
    require_once 'vendor/autoload.php';
    $pdo = new PDO("mysql:host=localhost;dbname=document_hub", "root", "");
    echo "<p style='color:green'>✅ Database connection successful</p>";
} catch (Exception $e) {
    echo "<p style='color:red'>❌ Database connection failed: {$e->getMessage()}</p>";
}

// 4. Test permissions
foreach (['storage', 'public/uploads'] as $dir) {
    if (is_writable($dir)) {
        echo "<p style='color:green'>✅ $dir is writable</p>";
    } else {
        echo "<p style='color:red'>❌ $dir is not writable</p>";
    }
}

echo "<h2>Next Steps:</h2>";
echo "<ol>";
echo "<li>Update .env with your database credentials</li>";
echo "<li>Import database/migration.sql</li>";
echo "<li>Visit your website URL</li>";
echo "</ol>";
?>