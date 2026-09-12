# Windmill REST API Technical Reference

## Overview

The `scrape-web-content` skill connects to a local Windmill instance to run the `scrape_markdown_article` job synchronously using the `run_wait_result` endpoint route.

## Endpoint Specification

- **Endpoint URL**: configured through `$env:WINDMILL_SCRAPE_URL`; no built-in default is used.
- **Route**: `/api/w/obsidian/jobs/run_wait_result/f/u/peterernst/scrape_markdown_article`
- **Method**: `POST`
- **Headers**:
  - `Content-Type: application/json; charset=utf-8`
  - `Authorization: Bearer <token>` using the secret supplied through `$env:WINDMILL_SCRAPE_TOKEN`

## Request Payload

A JSON object containing the target web page URL:

```json
{
  "url": "https://example.com/article"
}
```

## Response Schema

A JSON object returned upon successful extraction:

```json
{
  "ttr": 5,
  "source": "https://example.com/article",
  "article": "# Article Heading\n\nArticle body content in high-fidelity Markdown...",
  "frontmatter": {
    "title": "Article Title",
    "description": "Short summary or description of the article",
    "authors": ["Author Name", "Co-author"],
    "site": "Publisher Site Name",
    "image": "https://example.com/hero.png",
    "published": "2026-08-26T14:20:35+00:00",
    "publisher": "https://example.com",
    "type": "article"
  }
}
```

### Response Properties

- `ttr` (number): Estimated reading time in minutes.
- `source` (string): Canonical URL of the scraped source page.
- `article` (string): Full article body converted to clean, high-fidelity Markdown.
- `frontmatter` (object): Key-value dictionary containing metadata properties extracted from OpenGraph, Twitter cards, and HTML header tags.

## Environment Variables

| Variable | Description | Requirement |
| --- | --- | --- |
| `WINDMILL_SCRAPE_URL` | Full URL to the Windmill `run_wait_result` endpoint | Required; no default |
| `WINDMILL_SCRAPE_TOKEN` | Bearer token for authenticating against the Windmill API | Required; no default |

## HTTP Status Codes & Error Diagnostics

- **200 OK**: Request completed successfully. Parsed response is returned.
- **401 / 403 Unauthorized / Forbidden**: Invalid or expired Bearer token.
- **404 Not Found**: The workspace, path, or script does not exist on the Windmill server.
- **422 Unprocessable Entity**: The article extraction engine failed to parse the page (e.g., page lacks sufficient text, is a landing page, or encountered anti-scraping challenges).
- **500 Internal Server Error**: Windmill worker runtime failure.
- **Connection Refused**: Local Windmill service or Docker container is offline.
