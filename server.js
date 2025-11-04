// server.js
import express from "express";
import cors from "cors";
import pg from "pg";
import dotenv from "dotenv";

dotenv.config();

const { Pool } = pg;
const app = express();
const PORT = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl:
    process.env.NODE_ENV === "production"
      ? { rejectUnauthorized: false }
      : false,
});

// Middleware
app.use(
  cors({
    origin:
      process.env.NODE_ENV === "production"
        ? "https://sparking-creation-for-book-lovers.netlify.app"
        : "http://localhost:8000",
  })
);
app.use(express.json());

// Test database connection
pool.query("SELECT NOW()", (err, res) => {
  if (err) {
    console.error("Database connection error:", err);
  } else {
    console.log("Database connected successfully");
  }
});

// ============== BOOK ENDPOINTS ==============

// Get all books for a user
app.get("/api/books", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM books ORDER BY created_at DESC"
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching books:", err);
    res.status(500).json({ error: "Failed to fetch books" });
  }
});

// Get a single book by ID
app.get("/api/books/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const bookResult = await pool.query("SELECT * FROM books WHERE id = $1", [
      id,
    ]);

    if (bookResult.rows.length === 0) {
      return res.status(404).json({ error: "Book not found" });
    }

    const commentsResult = await pool.query(
      "SELECT * FROM comments WHERE book_id = $1 ORDER BY created_at DESC",
      [id]
    );

    const book = bookResult.rows[0];
    book.comments = commentsResult.rows;

    res.json(book);
  } catch (err) {
    console.error("Error fetching book:", err);
    res.status(500).json({ error: "Failed to fetch book" });
  }
});

// Add a new book
app.post("/api/books", async (req, res) => {
  try {
    const {
      id,
      title,
      author,
      thumbnail,
      description,
      publishedDate,
      pageCount,
      categories,
      isbn,
    } = req.body;

    const result = await pool.query(
      `INSERT INTO books (id, title, author, thumbnail, description, published_date, page_count, categories, isbn)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        id,
        title,
        author,
        thumbnail,
        description,
        publishedDate,
        pageCount,
        categories,
        isbn,
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Error adding book:", err);
    res.status(500).json({ error: "Failed to add book" });
  }
});

// Update a book
app.put("/api/books/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author } = req.body;

    const result = await pool.query(
      "UPDATE books SET title = $1, author = $2 WHERE id = $3 RETURNING *",
      [title, author, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Book not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error updating book:", err);
    res.status(500).json({ error: "Failed to update book" });
  }
});

// Delete a book
app.delete("/api/books/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Delete comments first (foreign key constraint)
    await pool.query("DELETE FROM comments WHERE book_id = $1", [id]);

    const result = await pool.query(
      "DELETE FROM books WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Book not found" });
    }

    res.json({ message: "Book deleted successfully" });
  } catch (err) {
    console.error("Error deleting book:", err);
    res.status(500).json({ error: "Failed to delete book" });
  }
});

// ============== COMMENT ENDPOINTS ==============

// Get all comments for a book
app.get("/api/books/:bookId/comments", async (req, res) => {
  try {
    const { bookId } = req.params;
    const result = await pool.query(
      "SELECT * FROM comments WHERE book_id = $1 ORDER BY created_at DESC",
      [bookId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching comments:", err);
    res.status(500).json({ error: "Failed to fetch comments" });
  }
});

// Add a comment to a book
app.post("/api/books/:bookId/comments", async (req, res) => {
  try {
    const { bookId } = req.params;
    const { id, text, page, type } = req.body;

    const result = await pool.query(
      `INSERT INTO comments (id, book_id, text, page, type)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [id, bookId, text, page || "", type || "note"]
    );
    // Map created_at to timestamp for frontend
    const comment = result.rows[0];
    comment.timestamp = comment.created_at;
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Error adding comment:", err);
    res.status(500).json({ error: "Failed to add comment" });
  }
});

// Update a comment
app.put("/api/comments/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { text, page } = req.body;

    const result = await pool.query(
      "UPDATE comments SET text = $1, page = $2 WHERE id = $3 RETURNING *",
      [text, page, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Comment not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error updating comment:", err);
    res.status(500).json({ error: "Failed to update comment" });
  }
});

// Delete a comment
app.delete("/api/comments/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "DELETE FROM comments WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Comment not found" });
    }

    res.json({ message: "Comment deleted successfully" });
  } catch (err) {
    console.error("Error deleting comment:", err);
    res.status(500).json({ error: "Failed to delete comment" });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
