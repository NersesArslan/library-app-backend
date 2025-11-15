--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15 (Homebrew)
-- Dumped by pg_dump version 14.15 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: nersesarslanian
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO nersesarslanian;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: books; Type: TABLE; Schema: public; Owner: nersesarslanian
--

CREATE TABLE public.books (
    id character varying(36) NOT NULL,
    title character varying(500) NOT NULL,
    author character varying(255) NOT NULL,
    thumbnail text,
    description text,
    published_date character varying(50),
    page_count integer,
    categories text[],
    isbn character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.books OWNER TO nersesarslanian;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: nersesarslanian
--

CREATE TABLE public.comments (
    id character varying(36) NOT NULL,
    book_id character varying(36) NOT NULL,
    text text NOT NULL,
    page character varying(20),
    type character varying(50) DEFAULT 'note'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comments OWNER TO nersesarslanian;

--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: nersesarslanian
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: nersesarslanian
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: idx_books_author; Type: INDEX; Schema: public; Owner: nersesarslanian
--

CREATE INDEX idx_books_author ON public.books USING btree (author);


--
-- Name: idx_books_created_at; Type: INDEX; Schema: public; Owner: nersesarslanian
--

CREATE INDEX idx_books_created_at ON public.books USING btree (created_at);


--
-- Name: idx_books_title; Type: INDEX; Schema: public; Owner: nersesarslanian
--

CREATE INDEX idx_books_title ON public.books USING btree (title);


--
-- Name: idx_comments_book_id; Type: INDEX; Schema: public; Owner: nersesarslanian
--

CREATE INDEX idx_comments_book_id ON public.comments USING btree (book_id);


--
-- Name: idx_comments_created_at; Type: INDEX; Schema: public; Owner: nersesarslanian
--

CREATE INDEX idx_comments_created_at ON public.comments USING btree (created_at);


--
-- Name: books update_books_updated_at; Type: TRIGGER; Schema: public; Owner: nersesarslanian
--

CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON public.books FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: comments update_comments_updated_at; Type: TRIGGER; Schema: public; Owner: nersesarslanian
--

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: comments comments_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nersesarslanian
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

