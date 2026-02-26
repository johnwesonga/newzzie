# AGENTS.md - newzzie Development Guide

## Build & Test Commands

```bash
# Run development server with hot reload
gleam run -m lustre/dev start

# Build for production
gleam build

# Run all tests
gleam test

# Run single test file
gleam test --test-module models_test

# Format code (must run before commit)
gleam format
```

## Architecture & Structure

**newzzie** is a Lustre web application for searching and browsing news articles using NewsAPI.

- `src/models.gleam` - Data types (Article, Source, Model, Msg) and state initialization
- `src/api.gleam` - NewsAPI HTTP client with rsvp for async requests
- `src/views.gleam` - Lustre UI components and HTML rendering
- `src/newzzie.gleam` - Main application (Elm Architecture: init, update, view)
- `test/` - Test files using gleeunit
- `priv/static/` - Compiled JavaScript and assets

**Dependencies**: lustre (UI framework), rsvp (HTTP client), gleam_json (JSON parsing)

## Code Style & Conventions

- **Architecture**: Elm Architecture pattern (Model → Msg → update → view)
- **Types**: Custom types for domain models; use `Type(field: Type)` syntax
- **Effects**: Use `effect.Effect(Msg)` for async operations (HTTP calls)
- **Error Handling**: Use `Result(T, Error)` for API calls; convert to Msg in handlers
- **Imports**: Group stdlib → lustre/framework → local modules
- **Naming**: Snake_case for functions, CamelCase for types/constructors
- **JSON**: Use gleam_json decoders for NewsAPI responses; define decoders per model

**See also**: [lustre/CLAUDE.md](/Users/johnwesonga/projects/gleam/lustre/CLAUDE.md) for framework patterns
