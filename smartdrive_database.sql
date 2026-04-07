-- SmartDrive Car Rental System Database
-- Database: smartdrive_db
-- Generated on: March 30, 2026

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS smartdrive_db;
USE smartdrive_db;

-- Drop tables if they exist (for clean setup)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS user_discount_claims;
DROP TABLE IF EXISTS discount_codes;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS wallet;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS settings;
SET FOREIGN_KEY_CHECKS = 1;

-- Users table
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    birthday DATE NOT NULL,
    address VARCHAR(255) NOT NULL,
    gender VARCHAR(50),
    phone VARCHAR(20),
    sr_points INT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- Cars table
CREATE TABLE cars (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    srPoints INT NOT NULL,
    image_url TEXT NOT NULL,
    features JSON,
    specs_transmission VARCHAR(50),
    specs_fuel VARCHAR(50),
    specs_seats INT,
    description TEXT,
    is_available TINYINT DEFAULT 1,
    status VARCHAR(50) DEFAULT 'available',
    lastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_is_available (is_available),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at)
);

-- Bookings table
CREATE TABLE bookings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    car_id VARCHAR(50) NOT NULL,
    referenceNumber VARCHAR(50) UNIQUE NOT NULL,
    pickupDate DATETIME NOT NULL,
    returnDate DATETIME NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    totalPrice DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    discount_applied DECIMAL(10,2) DEFAULT 0,
    discount_percentage INT,
    promo_code_used VARCHAR(50),
    pickup_location VARCHAR(255),
    return_location VARCHAR(255),
    rental_duration_days INT,
    insurance_included TINYINT DEFAULT 1,
    insurance_cost DECIMAL(10,2) DEFAULT 500.00,
    rating INT,
    notes TEXT,
    pwd_senior_status TINYINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_car_id (car_id),
    INDEX idx_pickup_date (pickupDate),
    INDEX idx_return_date (returnDate),
    INDEX idx_booking_date (booking_date),
    INDEX idx_status (status)
);

-- Transactions table
CREATE TABLE transactions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    booking_id INT UNSIGNED NULL,
    transaction_type VARCHAR(50) NOT NULL,
    points INT,
    description TEXT,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_transaction_type (transaction_type)
);

-- Payments table
CREATE TABLE payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_number VARCHAR(100) UNIQUE NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_booking_id (booking_id),
    INDEX idx_user_id (user_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_status (status)
);

-- Wallet table (SR Wallet)
CREATE TABLE wallet (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED UNIQUE NOT NULL,
    balance DECIMAL(10,2) DEFAULT 0,
    total_topups DECIMAL(10,2) DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    last_topup_date TIMESTAMP NULL,
    last_transaction_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Discount codes table
CREATE TABLE discount_codes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percentage INT,
    discount_type VARCHAR(50) DEFAULT 'percentage',
    description VARCHAR(255),
    min_spending DECIMAL(10,2) DEFAULT 0,
    min_bookings INT DEFAULT 0,
    max_uses INT,
    used_count INT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    valid_from DATETIME,
    valid_until DATETIME,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_is_active (is_active),
    INDEX idx_valid_from (valid_from),
    INDEX idx_valid_until (valid_until)
);

-- User discount claims table
CREATE TABLE user_discount_claims (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    discount_code_id INT UNSIGNED NOT NULL,
    claimed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_date TIMESTAMP NULL,
    booking_id INT UNSIGNED NULL,
    status VARCHAR(50) DEFAULT 'claimed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (discount_code_id) REFERENCES discount_codes(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
);

-- Settings table
CREATE TABLE settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT,
    description VARCHAR(255),
    setting_type VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT INTO settings (setting_key, setting_value, description, setting_type) VALUES
('INSURANCE_COST', '500', 'Default insurance cost per rental in PHP', 'decimal'),
('FIRST_TIME_DISCOUNT', '15', 'New member discount percentage', 'integer'),
('MIN_AGE', '21', 'Minimum renter age in years', 'integer'),
('CANCELLATION_FEE_PERCENTAGE', '10', 'Cancellation penalty percentage', 'integer'),
('LATE_FEE_MULTIPLIER', '1.5', 'Late return rate multiplier', 'decimal');

-- Insert admin user
INSERT INTO users (name, email, password, birthday, address, gender, phone, sr_points, is_active) VALUES
('Admin User', 'admin@smartrentals.com', '$2y$10$hashedpassword', '1990-01-01', 'Admin Address', 'male', '09171234567', 0, 1);

-- Insert sample discount codes
INSERT INTO discount_codes (code, discount_percentage, discount_type, description, min_spending, min_bookings, max_uses, is_active, valid_from, valid_until, category) VALUES
('WELCOME15', 15, 'percentage', '15% off first booking for new members', 0, 0, NULL, 1, '2024-01-01 00:00:00', '2026-12-31 23:59:59', 'new_member'),
('LOYAL10', 10, 'percentage', '10% off for standard members', 0, 1, NULL, 1, '2024-01-01 00:00:00', '2026-12-31 23:59:59', 'loyalty');

-- Insert sample cars (fleet)
INSERT INTO cars (id, name, type, price, srPoints, image_url, features, specs_transmission, specs_fuel, specs_seats, description, is_available, status) VALUES
('tesla-model-3', 'Tesla Model 3', 'Electric', 3500.00, 35, 'images/tesla-model-3.jpg', '["Autopilot", "Supercharger Access", "Glass Roof"]', 'Automatic', 'Electric', 5, 'Experience the future of driving with Tesla Model 3.', 1, 'available'),
('bmw-x5', 'BMW X5', 'Luxury SUV', 4500.00, 45, 'images/bmw-x5.jpg', '["All-Wheel Drive", "Leather Seats", "Navigation"]', 'Automatic', 'Gasoline', 5, 'Luxury SUV for your comfort.', 1, 'available'),
('lamborghini-huracan-evo', 'Lamborghini Huracán EVO', 'Sports Car', 15000.00, 150, 'images/lamborghini-huracan-evo.jpg', '["V10 Engine", "Carbon Fiber", "Racing Seats"]', 'Automatic', 'Gasoline', 2, 'Unleash the beast on the road.', 1, 'available'),
('toyota-corolla', 'Toyota Corolla', 'Economy', 1200.00, 12, 'images/toyota-corolla.jpg', '["Fuel Efficient", "Reliable"]', 'Automatic', 'Gasoline', 5, 'Reliable and economical choice.', 1, 'available'),
('ford-mustang', 'Ford Mustang', 'Sports Car', 5000.00, 50, 'images/ford-mustang.jpg', '["V8 Engine", "Convertible"]', 'Manual', 'Gasoline', 4, 'Classic American muscle car.', 1, 'available'),
('mercedes-benz-c-class', 'Mercedes-Benz C-Class', 'Luxury Sedan', 4000.00, 40, 'images/mercedes-benz-c-class.jpg', '["Premium Sound", "Massage Seats"]', 'Automatic', 'Gasoline', 5, 'Elegance and performance combined.', 1, 'available'),
('jeep-wrangler', 'Jeep Wrangler', 'SUV', 3000.00, 30, 'images/jeep-wrangler.jpg', '["4x4", "Off-Road Ready"]', 'Manual', 'Gasoline', 5, 'Adventure awaits with Jeep Wrangler.', 1, 'available'),
('audi-a4', 'Audi A4', 'Luxury Sedan', 3800.00, 38, 'images/audi-a4.jpg', '["Quattro AWD", "Virtual Cockpit"]', 'Automatic', 'Gasoline', 5, 'German engineering at its finest.', 1, 'available'),
('porsche-911', 'Porsche 911', 'Sports Car', 12000.00, 120, 'images/porsche-911.jpg', '["Turbocharged", "All-Wheel Drive"]', 'PDK', 'Gasoline', 4, 'Iconic sports car performance.', 1, 'available'),
('hyundai-tucson', 'Hyundai Tucson', 'SUV', 2500.00, 25, 'images/hyundai-tucson.jpg', '["Modern Design", "Tech Features"]', 'Automatic', 'Gasoline', 5, 'Modern SUV with advanced features.', 1, 'available'),
('nissan-gtr', 'Nissan GT-R', 'Sports Car', 10000.00, 100, 'images/nissan-gtr.jpg', '["Twin-Turbo V6", "AWD"]', 'Dual-Clutch', 'Gasoline', 4, 'Godzilla on wheels.', 1, 'available'),
('volkswagen-golf', 'Volkswagen Golf', 'Hatchback', 1800.00, 18, 'images/volkswagen-golf.jpg', '["Spacious", "Efficient"]', 'Automatic', 'Gasoline', 5, 'Versatile hatchback.', 1, 'available'),
('chevrolet-corvette', 'Chevrolet Corvette', 'Sports Car', 8000.00, 80, 'images/chevrolet-corvette.jpg', '["V8 Engine", "Aerodynamic"]', 'Manual', 'Gasoline', 2, 'American sports car legend.', 1, 'available'),
('lexus-rx', 'Lexus RX', 'Luxury SUV', 4200.00, 42, 'images/lexus-rx.jpg', '["Hybrid Option", "Luxury Interior"]', 'Automatic', 'Hybrid', 5, 'Luxury and efficiency.', 1, 'available');

-- Note: Password for admin is 'adminpassword' hashed with password_hash() in PHP
