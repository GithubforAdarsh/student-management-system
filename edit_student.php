
<?php
require_once 'config/database.php';

// Get student ID
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);

if (!$id || $id < 1) {
    die("Invalid student ID.");
}

$error = "";

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $course = trim($_POST['course'] ?? '');

    if ($name === '' || $email === '' || $course === '') {
        $error = "All fields are required.";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = "Please enter a valid email.";
    } else {

        $sql = "UPDATE students
                SET name = :name,
                    email = :email,
                    course = :course
                WHERE id = :id";

        $stmt = $pdo->prepare($sql);

        $stmt->execute([
            ':name' => $name,
            ':email' => $email,
            ':course' => $course,
            ':id' => $id
        ]);

        header("Location: index.php");
        exit;
    }
}

// Fetch existing student
$stmt = $pdo->prepare("SELECT * FROM students WHERE id = :id");
$stmt->execute([':id' => $id]);

$student = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$student) {
    die("Student not found.");
}

include 'includes/header.php';
?>

<h2>Edit Student</h2>

<?php if ($error !== ''): ?>
    <p style="color:red;">
        <?= htmlspecialchars($error) ?>
    </p>
<?php endif; ?>

<form method="POST">

    <label>Name:</label><br>
    <input type="text" name="name"
        value="<?= htmlspecialchars($student['name']) ?>"
        required>
    <br><br>

    <label>Email:</label><br>
    <input type="email" name="email"
        value="<?= htmlspecialchars($student['email']) ?>"
        required>
    <br><br>

    <label>Course:</label><br>
    <input type="text" name="course"
        value="<?= htmlspecialchars($student['course']) ?>"
        required>
    <br><br>

    <button type="submit">Update Student</button>
    <a href="index.php">Cancel</a>

</form>

<?php include 'includes/footer.php'; ?>
