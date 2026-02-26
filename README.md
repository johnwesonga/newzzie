# newzzie

A Lustre web application for browsing and searching news articles from around the world using the NewsApi.

## Features

- **Search articles** by keyword with real-time query validation
- **Browse top headlines** by country (US, UK, CA, DE, FR) with interactive filter buttons
- **Filter headlines** by news sources with comma-separated source IDs
- **Pagination** - Browse search results across multiple pages with Previous/Next navigation
- **Enter key search** - Trigger search by pressing Return/Enter in the search input
- **About page** - Learn about the application, its features, and technology stack
- **Client-side routing** with modem for SPA navigation
- **Responsive design** with Tailwind CSS
- **Type-safe JSON decoding** with Gleam
- **Async HTTP requests** with rsvp
- **Reactive UI** with Lustre framework

## Architecture

The application follows the Elm Architecture pattern with:
- **Models** (`src/models.gleam`) - Article, Source data types and application state (Model, Msg)
- **API Layer** (`src/api.gleam`) - NewsApi integration with three endpoints:
  - `everything()` - Search articles by query
  - `top_headlines()` - Get top news by country
  - `top_headlines_by_source()` - Get news from specific sources
- **Routing** (`src/routes.gleam`) - Client-side routes:
  - `Home` - Landing page with search and country filters
  - `Search(query)` - Search results page
  - `Headlines(country)` - Headlines for specific country
  - `HeadlinesBySources(sources)` - Headlines from specific sources
  - `About` - Information about the application
- **Views** (`src/views.gleam`) - UI components with route-based content switching
- **Main App** (`src/newzzie.gleam`) - Application initialization, update handlers, and modem integration

## Routes

The application supports the following URL patterns:
- `/` - Home page
- `/search/:query` - Search results for a keyword
- `/headlines/:country` - Top headlines for a specific country
- `/top-headlines/sources/:sources` - Headlines from comma-separated sources
- `/about` - Application information and details

## Dependencies

- [lustre](https://hex.pm/packages/lustre) - Web framework
- [modem](https://hex.pm/packages/modem) - Client-side routing
- [rsvp](https://hex.pm/packages/rsvp) - HTTP client for Lustre
- [gleam_json](https://hex.pm/packages/gleam_json) - JSON parsing

## Development

```sh
./startup.sh                    # Start the development server with hot reload
gleam test                      # Run tests
gleam build                     # Build for production
gleam format                    # Format code (required before commits)
```

## Testing

Tests use gleeunit. Run with:
```sh
gleam test
```

## Requirements

You'll need a free API key from [NewsApi.org](https://newsapi.org/) to use the application. Add your API key to the `newzzie.gleam` file where API calls are made.
