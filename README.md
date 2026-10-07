# SQL for Analysts Who Hate SQL: companion files

Free practice files for the book **SQL for Analysts Who Hate SQL: 50 Real Business Questions, One Query Each, Explained in Plain English** by Mathew Kariuki.

Every example in the book runs on Bean & Leaf Co., a fictional online shop selling coffee, tea and brewing gear in Australia, the UK and the US. This repository holds its data and every query from the book, so you can follow along.

## Download

Click the green **Code** button above, then **Download ZIP**. Unzip it anywhere on your computer.

## What's here

| Path | What it is |
| --- | --- |
| `data/bean_and_leaf.db` | The sample database (SQLite). This is the file the book uses. |
| `data/*.csv` | The same six tables as CSV files, for any other tool |
| `data/postgres_setup.sql` | Creates the tables in PostgreSQL and loads the CSVs |
| `queries/all_queries.sql` | All 50 queries from the book, plus all 50 "Try it" answers |

## Quick start (about 10 minutes)

1. Install **DB Browser for SQLite**, which is free, from [sqlitebrowser.org](https://sqlitebrowser.org).
2. Open `data/bean_and_leaf.db` with **Open Database**.
3. Go to the **Execute SQL** tab, type `SELECT * FROM customers;` and press Ctrl+Enter (Cmd+Return on a Mac).

You should see 2,025 customers. That's your first query.

### Using PostgreSQL instead

Open a terminal in the `data` folder and run:

```
psql -d your_database -f postgres_setup.sql
```

The book's queries are written for SQLite. Where PostgreSQL, SQL Server, MySQL or BigQuery differ, mostly with dates, the book has a note and Appendix C lists the changes.

## The tables

| Table | One row per | Rows |
| --- | --- | --- |
| customers | customer | 2,025 |
| products | product | 60 |
| orders | order | 6,796 |
| order_items | line on an order | 12,839 |
| marketing_spend | channel per month | 144 |
| support_tickets | support ticket | 1,470 |

The data covers 1 January 2024 to 31 December 2025. It is messy on purpose: duplicate customers, missing emails, inconsistent country spellings and a few typo orders. The book shows you how to find and handle each one.

## Get the book

- **PDF bundle with printable cheat sheets:** [mathewkariuki.gumroad.com/l/sql-for-analysts](https://mathewkariuki.gumroad.com/l/sql-for-analysts)
- **Paperback and Kindle:** on Amazon

## About

Bean & Leaf Co. and every person in its data are fictional. The data and queries are free to use for learning. The book itself is © 2026 Mathew Kariuki.

Spotted a problem with a query or the data? Please open an issue.
