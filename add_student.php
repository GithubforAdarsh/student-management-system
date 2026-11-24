
<?php
require_once 'config/database.php';

$error = '';
$name = '';
$email = '';
$course = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $course = trim($_POST['course'] ?? '');

    // Validate required fields
    if ($name === '' || $email === '' || $course === '') {

        $error = "All fields are required.";

    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {

        $error = "Please enter a valid email address.";

    } else {

        try {

            $sql = "INSERT INTO students (name, email, course)
                    VALUES (:name, :email, :course)";

            $stmt = $pdo->prepare($sql);

            $stmt->execute([
                ':name' => $name,
                ':email' => $email,
                ':course' => $course
            ]);

            header("Location: index.php");
            exit;

        } catch (PDOException $e) {

            // Handle duplicate email
            if (
                $e->getCode() == '23000' &&
                isset($e->errorInfo[1]) &&
                $e->errorInfo[1] == 1062
            ) {

                $error = "This email address is already registered.";

            } else {

                error_log($e->getMessage());
                $error = "Something went wrong. Please try again.";
            }
        }
    }
}

include 'includes/header.php';
?>

<div class="container">

    <h2>Add New Student</h2>

    <?php if ($error !== ''): ?>
        <p style="color: red;">
            <?= htmlspecialchars($error) ?>
        </p>
    <?php endif; ?>

    <form method="POST">

        <p>
            <label>Name:</label><br>
            <input
                type="text"
                name="name"
                value="<?= htmlspecialchars($name) ?>"
                required
            >
        </p>

        <p>
            <label>Email:</label><br>
            <input
                type="email"
                name="email"
                value="<?= htmlspecialchars($email) ?>"
                required
            >
        </p>

        <p>
            <label>Course:</label><br>
            <input
                type="text"
                name="course"
                value="<?= htmlspecialchars($course) ?>"
                required
            >
        </p>

        <button type="submit">Save Student</button>

        <a href="index.php">Cancel</a>

    </form>

</div>

<?php include 'includes/footer.php'; ?>

