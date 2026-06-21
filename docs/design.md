# Overall Idea

Build a Rust-based tool that analyzes git contributions per user by first
extracting commit data into JSONL files using scripts, then parsing that data in
Rust to generate insights.

The system is divided into three layers:

| Layer		| Function			|
|--------------	|-------------------------------|
|Scripts	| generate raw data (JSONL)	|
|Rust core	| parse and analyze data	|
|Frontend	| CLI / TUI / Web (future)	|

## Data Flow

Git repository
* shell script (git log)
* JSONL files (per user, per repo)
* Rust loader parses JSONL -> `Vec<Commit>`
* Contribution abstraction
* Analytics functions
* Output (stats / UI)

## Core Concepts
### Commit
A simple data structure representing one commit.

Fields:
-hash
-date
-subject
-email

Commit should only hold data, no heavy logic and basic functions.

### Contribution
Represents a type of contribution for a user.

Examples:
- Authored
- Reviewed
- (future: Tested, etc.)

Structure:
- kind (enum)
- list of commits
- Contribution
	- kind (Authored / Reviewed)
	- commits: `Vec<Commit>`

### User (future concept)
A user can have multiple contribution kinds:

User
- email
- authored: Contribution
- reviewed: Contribution

## Design Principles
- Scripts handle data generation
- Rust handles parsing and analysis
- Keep data and logic separate
- Start simple, evolve later

### Small Plan (v1)
- Script:
	- Generate JSONL for authored commits per user
- Rust:
	- Define Commit struct
	- Write JSONL parser -> `Vec<Commit>`
- Contribution:
	- Create Contribution struct with commits
	- Basic analytics:
	- count commits
	- filter by date
	- filter by year
- Simple main program:
	- load JSONL
	- print basic stats

### Medium Plan (v2)
- Add reviewed commits support
- Extend ContributionKind enum
- Add more filters:
	- by quarter
	- by custom range
- Improve stats:
	- commits per year
	- commits per month
- Add CLI interface

### Larger Plan (v3)
- TUI interface
- Web UI
- Multi-repo support
- Multiple users support
- Better querying system?
- Possibly caching/indexing?

## Storage And Loading Conventions

### Data Layout

Current layout per repository and user:

data/
- repo_name/
	- metadata.json
	- user_a/
		- authored.jsonl
		- reviewed.jsonl
		- tested.jsonl
	- user_b/
		- authored.jsonl
		- reviewed.jsonl
		- tested.jsonl

Notes:
- User directory naming is sanitized by scripts.
- Contribution filenames are enum-aligned and stable: authored, reviewed, tested.

### Repo Metadata (v1)

Each repository directory should have metadata.json for config and refresh state.

Suggested fields for v1:
- schema_version
- repo_name
- repo_path
- users (canonical user emails)
- contribution_kinds (authored, reviewed, tested)
- last_refresh_at

Reserved for later:
- checkpoints (for incremental refresh)

### Data Loading Semantics

Keep loading behavior simple for v1:
- Missing data is treated as empty data.
- Unknown files are ignored.
- Use lenient JSONL parsing by default (skip malformed lines and report warnings).
- Strict mode can be added later if needed.

### Refresh Strategy

Refresh rebuilds analytics data from local repository state.

Boundaries:
- Tool does not perform git fetch or git pull.
- User is responsible for updating local repository state.

Roadmap:
- v1: full refresh only.
- v1.1: selective refresh by user and/or contribution kind.
- v2: incremental refresh using stored checkpoints.

## User Lifecycle

### Initial Setup

1. User selects repository path.
2. User enters list of users to monitor.
3. Scripts generate JSONL data for each user and contribution kind.
4. Data is stored under data/<repo>/<user>/.

### Normal Usage

1. Start tool.
2. Select existing repository or add a new repository.
3. Select existing user or add a new user.
4. Select contribution kind.
5. Load contribution data.
6. Run analytics.
