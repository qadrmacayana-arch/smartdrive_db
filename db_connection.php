<?php
// Database configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'smartdrive_db');

// Create database connection
function getDBConnection() {
    static $conn = null;

    if ($conn === null) {
        try {
            $conn = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
                DB_USER,
                DB_PASS,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch (PDOException $e) {
            die("Database connection failed: " . $e->getMessage());
        }
    }

    return $conn;
}

// Helper functions for common database operations
function sanitizeInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

function getUserById($userId) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("SELECT * FROM users WHERE id = ? AND is_active = 1");
    $stmt->execute([$userId]);
    return $stmt->fetch();
}

function getUserByEmail($email) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ? AND is_active = 1");
    $stmt->execute([$email]);
    return $stmt->fetch();
}

function getAllCars($availableOnly = true) {
    $conn = getDBConnection();
    $sql = "SELECT * FROM cars";
    if ($availableOnly) {
        $sql .= " WHERE is_available = 1";
    }
    $sql .= " ORDER BY name ASC";

    $stmt = $conn->query($sql);
    return $stmt->fetchAll();
}

function getCarById($carId) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("SELECT * FROM cars WHERE id = ?");
    $stmt->execute([$carId]);
    return $stmt->fetch();
}

function getUserBookings($userId) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("
        SELECT b.*, c.name as car_name, c.image_url
        FROM bookings b
        JOIN cars c ON b.car_id = c.id
        WHERE b.user_id = ?
        ORDER BY b.booking_date DESC
    ");
    $stmt->execute([$userId]);
    return $stmt->fetchAll();
}

function getUserTransactions($userId) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("
        SELECT t.*, b.pickup_date, b.return_date, c.name as car_name
        FROM transactions t
        LEFT JOIN bookings b ON t.booking_id = b.id
        LEFT JOIN cars c ON b.car_id = c.id
        WHERE t.user_id = ?
        ORDER BY t.transaction_date DESC
    ");
    $stmt->execute([$userId]);
    return $stmt->fetchAll();
}

function updateUserPoints($userId, $points) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("UPDATE users SET sr_points = sr_points + ? WHERE id = ?");
    return $stmt->execute([$points, $userId]);
}

function addTransaction($userId, $type, $points, $description, $bookingId = null) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("
        INSERT INTO transactions (user_id, transaction_type, points, description, booking_id)
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $type, $points, $description, $bookingId]);

    // Update user points
    updateUserPoints($userId, $points);

    return $conn->lastInsertId();
}

function getSettings() {
    $conn = getDBConnection();
    $stmt = $conn->query("SELECT * FROM settings");
    $settings = [];
    while ($row = $stmt->fetch()) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }
    return $settings;
}

function getSetting($key) {
    $conn = getDBConnection();
    $stmt = $conn->prepare("SELECT setting_value FROM settings WHERE setting_key = ?");
    $stmt->execute([$key]);
    $result = $stmt->fetch();
    return $result ? $result['setting_value'] : null;
}
?>