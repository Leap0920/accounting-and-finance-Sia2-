<?php
require_once '../config/database.php';
require_once '../includes/session.php';

// Redirect to dashboard if already logged in
if (isLoggedIn()) {
    header("Location: dashboard.php");
    exit();
}

$error_message = '';
$success_message = '';

// Handle login form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = sanitize_input($_POST['username']);
    $password = $_POST['password'];

    if (empty($username) || empty($password)) {
        $error_message = "Please enter both username and password.";
    } else {
        $conn = getDBConnection();

        if (!$conn) {
            $error_message = "Database connection failed. Please try again later.";
        } else {
            // Prepare and execute query
            $stmt = $conn->prepare("SELECT id, username, password_hash, email, full_name, is_active FROM users WHERE username = ?");
            $stmt->bind_param("s", $username);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows == 1) {
                $user = $result->fetch_assoc();

                // Check if password hash is valid (starts with $2y$ or $2a$ for bcrypt)
                $hash_valid = strpos($user['password_hash'], '$2y$') === 0 || strpos($user['password_hash'], '$2a$') === 0;

                if (!$hash_valid) {
                    // Password hash format is invalid - likely needs fixing
                    $error_message = "Password format error detected. Please run <a href='../database/fix_user_passwords.php' style='color: #0A3D3D; text-decoration: underline;'>Fix User Passwords</a> to resolve this issue.";
                } elseif (password_verify($password, $user['password_hash'])) {
                    if ($user['is_active']) {
                        // Set session
                        setUserSession($user);

                        // Update last login
                        $update_stmt = $conn->prepare("UPDATE users SET last_login = NOW() WHERE id = ?");
                        $update_stmt->bind_param("i", $user['id']);
                        $update_stmt->execute();
                        $update_stmt->close();

                        // Log login activity
                        logActivity('login', 'authentication', 'User logged in successfully', $conn);

                        // Redirect to dashboard
                        header("Location: dashboard.php");
                        exit();
                    } else {
                        $error_message = "Your account has been deactivated. Please contact the administrator.";
                    }
                } else {
                    $error_message = "Invalid username or password.";
                }
            } else {
                $error_message = "Invalid username or password.";
            }

            $stmt->close();
            // Note: Don't close connection here as it's a global connection that might be used elsewhere
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Accounting and Finance System</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="stylesheet" href="../assets/css/style.css?v=<?php echo time(); ?>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">
</head>

<body class="login-page">
    <div class="login-wrapper">
        <!-- Left Section: Branding & Hero -->
        <div class="login-left">
            <div class="login-left-content">
                <div class="brand-section">
                    <img src="../assets/image/LOGO.png" alt="Evergreen Logo" class="brand-logo">
                    <div class="brand-text">
                        <h1>EVERGREEN</h1>
                        <p>SECURE • INVEST • ACHIEVE</p>
                    </div>
                </div>

                <h2 class="hero-text">Empowering your financial <br>future.</h2>
                <p class="hero-desc">Access your professional accounting dashboard with enterprise-grade security and
                    precision analytics.</p>

                <div class="feature-badges">
                    <div class="feature-badge">
                        <div class="badge-icon-yellow">
                            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor"
                                stroke-width="4" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                        </div>
                        <span>SSL Encrypted</span>
                    </div>
                    <div class="feature-badge">
                        <div class="badge-icon-yellow">
                            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor"
                                stroke-width="4" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="18" y1="20" x2="18" y2="10"></line>
                                <line x1="12" y1="20" x2="12" y2="4"></line>
                                <line x1="6" y1="20" x2="6" y2="14"></line>
                            </svg>
                        </div>
                        <span>Real-time Data</span>
                    </div>
                </div>
            </div>

            <!-- Decorative elements -->
            <div class="circle circle-1"></div>
            <div class="circle circle-2"></div>
            <div class="circle circle-3"></div>
        </div>

        <!-- Right Section: Login Form -->
        <div class="login-right">
            <div class="login-form-container">
                <div class="login-title-section">
                    <h2>ACCOUNTING AND FINANCE</h2>
                    <p>Admin Login</p>
                </div>

                <?php if (!empty($error_message)): ?>
                    <div class="alert alert-error">
                        <?php echo $error_message; ?>
                    </div>
                <?php endif; ?>

                <?php if (!empty($success_message)): ?>
                    <div class="alert alert-success">
                        <?php echo $success_message; ?>
                    </div>
                <?php endif; ?>

                <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="login-form">
                    <div class="form-group">
                        <label for="username">USERNAME</label>
                        <div class="input-with-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                <circle cx="12" cy="7" r="4" />
                            </svg>
                            <input type="text" id="username" name="username" required autofocus
                                placeholder="Enter your username">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">PASSWORD</label>
                        <div class="input-with-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                            </svg>
                            <input type="password" id="password" name="password" required
                                placeholder="Enter your password">
                        </div>
                    </div>

                    <div class="form-extras">
                        <label class="remember-me">
                            <input type="checkbox" name="remember">
                            <span>Remember me</span>
                        </label>
                    </div>

                    <button type="submit" class="btn-login">
                        LOGIN
                    </button>
                </form>

                <div class="login-footer">
                    <p>&copy; 2026 EVERGREEN ACCOUNTING & FINANCE. ALL RIGHTS RESERVED.</p>
                </div>
            </div>
        </div>
    </div>
</body>

</html>