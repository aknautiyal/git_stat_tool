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
