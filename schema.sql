-- schema.sql
-- PostgreSQL Database Schema for Library App

-- Drop existing tables if they exist
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS books CASCADE;

-- Books table
CREATE TABLE books (
  id VARCHAR(36) PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  author VARCHAR(255) NOT NULL,
  thumbnail TEXT,
  description TEXT,
  published_date VARCHAR(50),
  page_count INTEGER,
  categories TEXT[],
  isbn VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments/Quotes table
CREATE TABLE comments (
  id VARCHAR(36) PRIMARY KEY,
  book_id VARCHAR(36) NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  page VARCHAR(20),
  type VARCHAR(50) DEFAULT 'note',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better query performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);
CREATE INDEX idx_books_created_at ON books(created_at);
CREATE INDEX idx_comments_book_id ON comments(book_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update updated_at
CREATE TRIGGER update_books_updated_at
  BEFORE UPDATE ON books
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();