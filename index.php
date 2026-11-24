
<?php
require_once 'config/database.php';
include 'includes/header.php';

try {
    $sql = "SELECT * FROM students ORDER BY id DESC";
    $stmt = $pdo->query($sql);
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    error_log($e->getMessage());
    $students = [];
    $dbError = true;
}
?>

<h2>Student Management Dashboard</h2>

<a href="add_student.php" class="btn">+ Add New Student</a>

<?php if (!empty($dbError)): ?>
    <p>Unable to load student records. Check the server logs.</p>
<?php else: ?>

<table border="1" cellpadding="10" cellspacing="0" width="100%">
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Course</th>
        <th>Actions</th>
    </tr>

    <?php foreach ($students as $row): ?>
    <tr>
        <td><?= (int)$row['id'] ?></td>
        <td><?= htmlspecialchars($row['name']) ?></td>
        <td><?= htmlspecialchars($row['email']) ?></td>
        <td><?= htmlspecialchars($row['course']) ?></td>
        <td>
            <a href="edit_student.php?id=<?= (int)$row['id'] ?>">Edit</a>
            |
            <a href="delete_student.php?id=<?= (int)$row['id'] ?>"
               onclick="return confirm('Delete this student?')">
               Delete
            </a>
        </td>
    </tr>
    <?php endforeach; ?>
</table>

<?php endif; ?>

<?php include 'includes/footer.php'; ?>

