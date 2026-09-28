# Georgia Bite — Multi-Region Restaurant Directory & Data Schema

## Overview
Engineered a production-grade relational database schema, custom Row Level Security (RLS) policies, geospatial search indexes, and automated data audit triggers in PostgreSQL (Supabase) for **Georgia Bite**, a regional restaurant discovery and lead-generation platform[cite: 6, 7].

## Key Features & Schema Architecture
* **Relational Multi-Tenant Model**: Normalized relational tables mapping restaurants, regional search clusters (Atlanta Metro, Savannah Coastal, Augusta CSRA), categories, asset galleries, and user favorites.
* **Geospatial & Performance Indexing**: Multi-column indexing on coordinate pairs (`latitude`, `longitude`), city lookup fields, and ratings for high-speed search queries.
* **Data Integrity Guardrails**: Domain validation enforced via strict `CHECK` constraints (price tiers, rating bounds, and feature enumerations).
* **Automated PL/pgSQL Triggers**: Procedural trigger functions handling real-time `updated_at` timestamp management on table mutations.
* **Row Level Security (RLS)**: Fine-grained PostgreSQL RLS policies securing public access vectors and admin data modification routes[cite: 7].

## Repository Structure
* `schema.sql` — Full PostgreSQL DDL definitions, indexing strategies, trigger functions, RLS security policies, and seed data[cite: 7].
