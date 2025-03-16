# استخدم صورة PHP مع Apache
FROM php:8.2-apache

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

# تعيين مجلد العمل إلى /var/www/html
WORKDIR /var/www/html

# نسخ كل الملفات إلى الحاوية
COPY . .

# تثبيت الحزم المطلوبة
RUN composer install --no-dev --optimize-autoloader

# إعداد الصلاحيات الصحيحة
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# فتح المنفذ 80 للسماح بطلبات API
EXPOSE 80

# تشغيل Apache بعد تفعيل mod_rewrite
CMD ["apache2-foreground"]
