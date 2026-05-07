#!/bin/bash
# ========================================
#  DocumentHub Complete Setup Script
#  Version: 1.0.0
# ========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen
clear

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       DocumentHub Setup Assistant         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${CYAN}📦 $1${NC}"
}

# Check if running as root (for Linux/Mac)
check_root() {
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
        if [ "$EUID" -ne 0 ]; then
            print_info "Some operations may require sudo. You might be asked for your password."
        fi
    fi
}

# Detect operating system
detect_os() {
    case "$OSTYPE" in
        linux*)   OS="Linux" ;;
        darwin*)  OS="Mac" ;;
        msys*)    OS="Windows" ;;
        cygwin*)  OS="Windows" ;;
        *)        OS="Unknown" ;;
    esac
    print_info "Detected OS: $OS"
}

# Check PHP installation
check_php() {
    print_step "Checking PHP installation..."
    
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -v 2>&1 | grep -oP 'PHP \K[0-9]+\.[0-9]+' | head -1)
        print_success "PHP $PHP_VERSION is installed"
        
        # Check PHP version
        if (( $(echo "$PHP_VERSION >= 7.4" | bc -l) )); then
            print_success "PHP version is compatible"
        else
            print_error "PHP version must be 7.4 or higher. Current: $PHP_VERSION"
            exit 1
        fi
    else
        print_error "PHP is not installed"
        echo ""
        echo "Please install PHP 7.4 or higher:"
        echo "  - XAMPP: https://www.apachefriends.org/"
        echo "  - WAMP: https://www.wampserver.com/"
        echo "  - Linux: sudo apt-get install php"
        echo "  - Mac: brew install php"
        exit 1
    fi
}

# Check MySQL installation
check_mysql() {
    print_step "Checking MySQL installation..."
    
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version 2>&1 | grep -oP 'Distrib \K[0-9]+\.[0-9]+')
        print_success "MySQL $MYSQL_VERSION is installed"
    else
        print_error "MySQL client not found"
        echo ""
        echo "Please install MySQL:"
        echo "  - XAMPP already includes MySQL"
        echo "  - Linux: sudo apt-get install mysql-server"
        echo "  - Mac: brew install mysql"
        echo ""
        print_info "Continuing setup... You'll need MySQL to complete the database setup."
    fi
}

# Check Composer installation
check_composer() {
    print_step "Checking Composer installation..."
    
    if command -v composer &> /dev/null; then
        COMPOSER_VERSION=$(composer --version 2>&1 | grep -oP 'Composer version \K[0-9]+\.[0-9]+')
        print_success "Composer $COMPOSER_VERSION is installed"
    else
        print_info "Composer not found. Installing Composer..."
        install_composer
    fi
}

# Install Composer
install_composer() {
    print_step "Installing Composer..."
    
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    
    # Verify installer
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    
    # Move composer to global location
    if [[ "$OS" == "Linux" || "$OS" == "Mac" ]]; then
        sudo mv composer.phar /usr/local/bin/composer
        print_success "Composer installed globally"
    else
        print_info "Composer.phar created. Use 'php composer.phar' instead of 'composer'"
    fi
}

# Create .env file
create_env_file() {
    print_step "Setting up environment configuration..."
    
    if [ -f .env ]; then
        print_info ".env file already exists"
        read -p "Do you want to overwrite it? (y/n): " OVERWRITE
        if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
            print_info "Keeping existing .env file"
            return
        fi
    fi
    
    # Create .env file
    cat > .env << 'ENVEOF'
# Database Configuration
DB_HOST=localhost
DB_NAME=document_hub
DB_USER=root
DB_PASS=
DB_CHARSET=utf8mb4

# Application Configuration
APP_NAME=DocumentHub
APP_URL=http://localhost/document-hub
APP_ENV=development
APP_DEBUG=true

# Mail Configuration
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls

# Payment Gateway Keys (Optional)
STRIPE_KEY=
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=
PAYPAL_CLIENT_ID=
PAYPAL_SECRET=

# Security Keys
JWT_SECRET=
ENCRYPTION_KEY=

# File Upload Settings
UPLOAD_MAX_SIZE=52428800
ALLOWED_EXTENSIONS=pdf,doc,docx,xls,xlsx,ppt,pptx,txt,zip,rar
ENVEOF

    print_success ".env file created"
}

# Create required directories
create_directories() {
    print_step "Creating directory structure..."
    
    DIRECTORIES=(
        "storage/documents/2024"
        "storage/thumbnails"
        "storage/logs"
        "storage/cache"
        "storage/backups"
        "storage/temp"
        "public/uploads"
        "public/assets/images/icons"
        "public/assets/css"
        "public/assets/js"
    )
    
    for dir in "${DIRECTORIES[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Created: $dir"
        else
            print_info "Exists: $dir"
        fi
    done
}

# Set permissions
set_permissions() {
    print_step "Setting file permissions..."
    
    # Make storage directories writable
    if [[ "$OS" == "Linux" || "$OS" == "Mac" ]]; then
        chmod -R 755 storage/
        chmod -R 777 storage/logs/
        chmod -R 777 storage/cache/
        chmod -R 777 storage/temp/
        chmod -R 777 public/uploads/
        print_success "Permissions set (Unix)"
    else
        print_info "On Windows, ensure these folders have write permissions:"
        echo "  - storage/"
        echo "  - public/uploads/"
    fi
}

# Install PHP dependencies
install_dependencies() {
    print_step "Installing PHP dependencies..."
    
    if [ -f composer.json ]; then
        if [[ "$OS" == "Windows" ]]; then
            php composer.phar install --no-interaction
        else
            composer install --no-interaction
        fi
        
        if [ $? -eq 0 ]; then
            print_success "Dependencies installed successfully"
        else
            print_error "Failed to install dependencies"
            exit 1
        fi
    else
        print_info "composer.json not found. Creating it..."
        create_composer_json
        install_dependencies
    fi
}

# Create composer.json if not exists
create_composer_json() {
    cat > composer.json << 'EOF'
{
    "name": "documenthub/app",
    "description": "Professional Document Download Platform",
    "type": "project",
    "require": {
        "php": ">=7.4",
        "phpmailer/phpmailer": "^6.5",
        "stripe/stripe-php": "^10.0",
        "vlucas/phpdotenv": "^5.4"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "App\\Controllers\\": "src/Controllers/",
            "App\\Models\\": "src/Models/",
            "App\\Services\\": "src/Services/",
            "App\\Middleware\\": "src/Middleware/"
        }
    }
}
EOF
    print_success "composer.json created"
}

# Setup database
setup_database() {
    print_step "Database Setup"
    echo ""
    
    read -p "Enter MySQL host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    read -p "Enter MySQL username [root]: " DB_USER
    DB_USER=${DB_USER:-root}
    
    read -s -p "Enter MySQL password (hidden): " DB_PASS
    echo ""
    
    read -p "Enter database name [document_hub]: " DB_NAME
    DB_NAME=${DB_NAME:-document_hub}
    
    # Test MySQL connection
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" &> /dev/null
    if [ $? -ne 0 ]; then
        print_error "Cannot connect to MySQL. Please check your credentials."
        return 1
    fi
    
    print_success "MySQL connection successful"
    
    # Create database
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" &> /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Database '$DB_NAME' created"
    else
        print_error "Failed to create database"
        return 1
    fi
    
    # Import schema
    if [ -f "database/migration.sql" ]; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < database/migration.sql
        
        if [ $? -eq 0 ]; then
            print_success "Database schema imported successfully"
        else
            print_error "Failed to import database schema"
            return 1
        fi
    else
        print_error "database/migration.sql not found"
        return 1
    fi
    
    # Update .env with database settings
    if [[ "$OS" == "Mac" ]]; then
        sed -i '' "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
        sed -i '' "s/DB_NAME=.*/DB_NAME=$DB_NAME/" .env
        sed -i '' "s/DB_USER=.*/DB_USER=$DB_USER/" .env
        sed -i '' "s/DB_PASS=.*/DB_PASS=$DB_PASS/" .env
    else
        sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
        sed -i "s/DB_NAME=.*/DB_NAME=$DB_NAME/" .env
        sed -i "s/DB_USER=.*/DB_USER=$DB_USER/" .env
        sed -i "s/DB_PASS=.*/DB_PASS=$DB_PASS/" .env
    fi
    
    print_success "Database configuration updated in .env"
}

# Generate security keys
generate_keys() {
    print_step "Generating security keys..."
    
    if command -v openssl &> /dev/null; then
        JWT_SECRET=$(openssl rand -base64 32)
        ENCRYPTION_KEY=$(openssl rand -base64 32)
    else
        JWT_SECRET=$(php -r "echo bin2hex(random_bytes(32));")
        ENCRYPTION_KEY=$(php -r "echo bin2hex(random_bytes(32));")
    fi
    
    if [[ "$OS" == "Mac" ]]; then
        sed -i '' "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
        sed -i '' "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=$ENCRYPTION_KEY/" .env
    else
        sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env
        sed -i "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=$ENCRYPTION_KEY/" .env
    fi
    
    print_success "Security keys generated"
}

# Create a test page
create_test_page() {
    print_step "Creating test page..."
    
    cat > test.php << 'EOF'
<?php
echo "<h1>DocumentHub Test Page</h1>";

// Test PHP
echo "<h2>PHP Version: " . phpversion() . "</h2>";

// Test MySQL
try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=document_hub",
        "root",
        ""
    );
    echo "<p style='color:green'>✅ Database connection successful</p>";
} catch(PDOException $e) {
    echo "<p style='color:red'>❌ Database connection failed: " . $e->getMessage() . "</p>";
}

// Test directories
$dirs = ['storage', 'public/uploads'];
foreach ($dirs as $dir) {
    if (is_writable($dir)) {
        echo "<p style='color:green'>✅ $dir is writable</p>";
    } else {
        echo "<p style='color:red'>❌ $dir is not writable</p>";
    }
}
?>
EOF
    print_success "Test page created (test.php)"
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Setup Completed Successfully! 🎉      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📋 Quick Start Guide:${NC}"
    echo ""
    echo -e "${YELLOW}1. Start your web server:${NC}"
    echo "   - XAMPP: Open XAMPP Control Panel > Start Apache & MySQL"
    echo "   - PHP Built-in: php -S localhost:8000 -t public/"
    echo ""
    echo -e "${YELLOW}2. Access the website:${NC}"
    echo "   http://localhost/document-hub"
    echo "   http://localhost:8000"
    echo ""
    echo -e "${YELLOW}3. Test your installation:${NC}"
    echo "   http://localhost/document-hub/test.php"
    echo ""
    echo -e "${YELLOW}4. Admin Login:${NC}"
    echo "   Email: admin@documenthub.com"
    echo "   Password: admin123"
    echo ""
    echo -e "${RED}⚠️  Important: Change the admin password immediately!${NC}"
    echo ""
    echo -e "${CYAN}📁 Project Structure:${NC}"
    echo "   public/       - Web accessible files"
    echo "   src/          - Application source code"
    echo "   storage/      - File storage"
    echo "   views/        - Template files"
    echo ""
    echo -e "${CYAN}📝 Need Help?${NC}"
    echo "   Check logs: storage/logs/error.log"
    echo "   Documentation: README.md"
    echo ""
}

# Main execution
main() {
    check_root
    detect_os
    echo ""
    
    # Run checks
    check_php
    check_mysql
    check_composer
    echo ""
    
    # Setup steps
    create_env_file
    echo ""
    
    create_directories
    echo ""
    
    set_permissions
    echo ""
    
    install_dependencies
    echo ""
    
    # Ask for database setup
    read -p "Do you want to setup the database now? (y/n): " SETUP_DB
    if [[ "$SETUP_DB" == "y" || "$SETUP_DB" == "Y" ]]; then
        setup_database
        echo ""
    fi
    
    generate_keys
    echo ""
    
    create_test_page
    echo ""
    
    # Show completion
    show_completion
}

# Run main function
main