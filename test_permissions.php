// test_permissions.php
<?php
$dirs = ['storage', 'public/uploads'];

foreach ($dirs as $dir) {
    if (is_writable($dir)) {
        echo "✅ {$dir} is writable\n";
    } else {
        echo "❌ {$dir} is NOT writable\n";
    }
}