## Project Structure

locally-backend/
├── cmd/                  # Entrypoints (main.go for app/server binaries)
│   └── locally/          # main backend server, config, bootstrapping
├── internal/
│   ├── user/             # user/accounts profile logic, handlers, models
|   ├── auth/             # user authentication logic
│   ├── skills/           # skill/category logic, handlers, models
│   ├── jobs/             # job posting logic, handlers, models
│   ├── proposals/        # proposals/bidding domain (handlers, models)
│   ├── contracts/        # contracts, milestones, time logs, attachments
│   ├── payments/         # transactions, wallet logic
│   ├── messaging/        # messages, attachments, conversations
│   ├── reviews/          # reviews & ratings logic
│   ├── notifications/    # notification, delivery, settings
│   ├── disputes/         # disputes/resolution logic
│   ├── portfolio/        # user portfolios/projects
│   ├── middleware/       # shared http/gRPC middleware (auth, logging)
│   ├── db/               # database initialization, migrations
│   ├── config/           # configuration utilities
│   ├── api/              # OpenAPI/Swagger definitions, docs
│   ├── util/             # common reusable utilities
│   └── tests/            # integration/unit tests
├── pkg/                  # helper packages, libraries (extraction-ready)
├── scripts/              # for build, test, coverage, CI/CD
├── docs/                 # additional architecture, API, setup docs
├── go.mod, go.sum        # go modules
├── Dockerfile            # for containerization
└── README.md             # overview and setup guide

## `sqlc` CLI tool

```
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

> [!TIP]
> Run `sqlc generate` after any SQL schema or query change.

## PostgreSQL driver dependency (`pgx`)

```
go get github.com/jackc/pgx/v5
```

