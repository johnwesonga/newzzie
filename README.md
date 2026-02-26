# newzzie

A Lustre web application for browsing and searching news articles from around the world using the NewsApi.

Built using AmpCode

## Features

- **Search articles** by keyword with real-time query validation and Enter key support
- **Browse top headlines** by country (US, UK, CA, DE, FR) with interactive filter buttons
- **Filter headlines** by news sources with comma-separated source IDs
- **Pagination** - Browse search results across multiple pages with Previous/Next navigation
- **localStorage caching** - Articles are cached per page for instant access on repeat visits
- **About page** - Learn about the application, its features, and technology stack
- **Debugging logs** - Browser console logs track all localStorage operations and page navigation
- **Client-side routing** with modem for SPA navigation
- **Responsive design** with Tailwind CSS
- **Type-safe JSON decoding** with Gleam
- **Async HTTP requests** with rsvp
- **Reactive UI** with Lustre framework

## Architecture

The application follows the Elm Architecture pattern with:
- **Models** (`src/models.gleam`) - Article, Source data types and application state (Model, Msg)
- **API Layer** (`src/api.gleam`) - NewsApi integration with pagination support:
  - `everything()` - Search articles by query with page number
  - `top_headlines()` - Get top news by country with page number
  - `top_headlines_by_source()` - Get news from specific sources with page number
  - Returns both parsed articles and raw JSON string for caching
- **Storage** (`src/storage.gleam`) - Browser localStorage integration:
  - Cache articles with key based on query/country and page number
  - Retrieve cached articles for repeat visits
  - JavaScript FFI (`src/storage_ffi.mjs`) handles low-level storage operations with error handling
- **Messages** (`src/messages.gleam`) - Update handlers for all user actions including pagination
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

## Debugging

Open the browser DevTools console to see detailed logging:
- **[Storage]** prefix - localStorage cache operations with hit/miss status and sizes
- **[Messages]** prefix - Page navigation and cache key generation

This makes it easy to understand how the caching system works and debug issues.

## How Caching Works

1. When articles are fetched from the API, they're automatically cached to localStorage
2. Cache keys are based on the search query/country and page number (e.g., `search_bitcoin_page_1`)
3. On pagination, the app checks if the requested page is cached
4. If cached, it fetches fresh data to stay current (configurable for lazy loading in future)
5. All cache operations are logged to the browser console for debugging

## Requirements

You'll need a free API key from [NewsApi.org](https://newsapi.org/) to use the application. The API key is configured in `src/api.gleam` as a module constant.
