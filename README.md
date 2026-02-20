# newzzie

A Lustre web application for browsing and searching news articles from around the world using the NewsApi.

## Features

- Search news articles by keyword
- Browse top headlines by country
- Filter headlines by news sources
- Type-safe JSON decoding with Gleam
- Async HTTP requests with rsvp
- Lustre framework for reactive UI

## Architecture

The application is built with:
- **Models** (`src/models.gleam`) - Article and Source data types from NewsApi
- **API Layer** (`src/api.gleam`) - NewsApi integration with three endpoints:
  - `everything()` - Search articles by query
  - `top_headlines()` - Get top news by country
  - `top_headlines_by_source()` - Get news from specific sources
- **Frontend** (`src/newzzie.gleam`) - Lustre web UI

## Dependencies

- [lustre](https://hex.pm/packages/lustre) - Web framework
- [rsvp](https://hex.pm/packages/rsvp) - HTTP client for Lustre
- [gleam_json](https://hex.pm/packages/gleam_json) - JSON parsing

## Development

```sh
gleam run -m lustre/dev start   # Run the lustre development server
```

## Requirements

You'll need a free API key from [NewsApi.org](https://newsapi.org/) to use the application.
