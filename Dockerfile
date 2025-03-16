# استخدم صورة PHP مع Apache
FROM php:8.1-apache

# تثبيت الإضافات المطلوبة لـ Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# تفعيل mod_rewrite لدعم API بشكل صحيح
RUN a2enmod rewrite

# تعيين مجلد العمل إلى /var/www
WORKDIR /var/www

# نسخ ملفات Laravel إلى الحاوية مع استثناء الملفات غير الضرورية
COPY . . 

# ضبط DocumentRoot إلى مجلد public في Laravel
RUN sed -i 's|/var/www/html|/var/www/public|g' /etc/apache2/sites-available/000-default.conf

# تثبيت الحزم المطلوبة باستخدام Composer
RUN composer install --no-dev --optimize-autoloader

# ضبط الأذونات الصحيحة للـ Storage و Cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# نسخ ملف البيئة إذا لم يكن موجودًا
RUN cp .env.example .env || true

# تشغيل Laravel Migration و Cache
RUN php artisan key:generate && php artisan config:cache && php artisan migrate --force

# فتح المنفذ 80 للسماح بطلبات API
EXPOSE 80

# تشغيل Apache بعد تفعيل mod_rewrite
CMD ["apache2-foreground"]
