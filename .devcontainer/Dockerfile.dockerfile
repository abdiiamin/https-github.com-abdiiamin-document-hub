FROM mcr.microsoft.com/devcontainers/php:8.1

# Install MySQL client and other tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    mysql-client \
    mariadb-server \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Start MySQL service
RUN service mariadb start
