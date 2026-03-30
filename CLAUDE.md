# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Prime directive
- Never ever push anything or ask for permission to push anything. The only thing you w

## What This App Is

**Vita-Min** is a Rails tax filing platform with three main components:
- **GYR (Get Your Refund)** — federal tax intake, document collection, and IRS submission
- **State File** — state tax filing (AZ, NY, and others)
- **Hub** — volunteer/staff portal for managing tax preparation workflow
- we will be ignorning the statefile aspect of the project unless explicitly asked about it 

## Commands

### Development
```bash
bin/setup              # First-time setup (installs deps, DBs, IRS schemas, etc.)
foreman start          # Start Rails + Delayed Job worker + Webpack dev server
```

### Tests
```bash
bin/test               # Full suite (RSpec + Jest, parallelized)
rspec spec/path/to/file_spec.rb   # Single spec file
rspec --only-failures  # Re-run failures
bin/test state_file    # Run only state file tests
yarn jest              # JavaScript tests only
COVERAGE=y rspec       # With coverage report
CHROME=y rspec         # With visible Chrome (for debugging feature specs)
```

### Linting
```bash
rubocop app lib        # Ruby linter
```

### Database
```bash
docker compose up --wait -d db    # Start PostgreSQL (required for local dev)
rails db:migrate
rails db:seed
```

### Other
```bash
rake setup:unzip_efile_schemas    # Re-download IRS XML schemas (in vendor/irs)
rails setup:download_gyr_efiler   # Re-download Java CLI for IRS SOAP calls
```

## Architecture

### Request Flow

Controllers are namespaced by product area:
- `hub/` — staff/volunteer portal
- `portal/` — client-facing portal
- `diy/` — state file self-service
- `ctc/` — Child Tax Credit flow
- `state_file/` — state return intake

### Key Layers

**Form Objects** (`app/forms/`) — Handle user input validation and transformation; kept separate from ActiveRecord models.

**Service Objects** (`app/services/`) — Extracted business logic (e.g., `GyrEfilerService` bridges to a Java CLI for IRS SOAP submissions).

**Efile Module** (`app/lib/efile/`) — XML calculation logic that converts intake data into IRS schema-compliant XML. Calculations are designed to be explainable via a debug UI.

**Submission Builder** (`app/lib/submission_builder/`) — Assembles full submission XML per tax year.

**PDF Filler** (`app/lib/pdf_filler/`) — Populates PDF tax forms from the calculated XML data.

**State Machines** (`app/state_machines/`) — Statesman gem manages `EfileSubmission` states (e.g., bundling → transmitted → accepted/rejected).

**Background Jobs** (`app/jobs/`) — Delayed Job for async work: file generation, IRS submissions, notifications.

### Data Model Highlights

- `Intake` / `StateFileNyIntake` / `StateFileAzIntake` — core user data collected during intake
- `EfileSubmission` — represents a filing sent (or to be sent) to the IRS; has state machine
- `Document` — user-uploaded documents (stored in S3)
- `TaxReturn` — associates an intake with a tax year and assigned preparer

### Multi-tenancy

The codebase serves multiple products (GYR, StateFile, CTC) and sites (getyourrefund.org, mireembolso.org, etc.) from one Rails app. Feature flags (Flipper) control rollouts per product.

### IRS Integration

`gyr-efiler` is a separate Java service (downloaded to `vendor/` at setup) that handles SOAP communication with the IRS. Rails calls it via `GyrEfilerService`. IRS XML schemas live in `vendor/irs/` (downloaded, not committed).

## Testing Patterns

- Feature specs use Capybara + Selenium (Chrome). Use `screenshot: true` or `screenshot_after` for debugging.
- Parallel test execution uses `turbo_tests`; test DBs are named `vita-min_test1`, `vita-min_test2`, etc.
- Accessibility is tested with `axe-core-rspec` / `axe-core-capybara`.
- Visual regression via Percy: `bin/percy` compares main vs. current branch.


