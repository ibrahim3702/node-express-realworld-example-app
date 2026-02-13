# Node Express RealWorld — README

This README explains how to run this project with Docker and how to perform SonarQube analysis locally (or in CI).

## Prerequisites
- Docker installed and running
- Node.js and npm (for local commands / generating coverage)
- A SonarQube server (local Docker or hosted) and a Sonar token

---

## Docker — Build and Run

1. Build the Docker image (run from repository root):

```bash
docker build -t realworld-app:latest .
```

2. Run the container (example):

```bash
# Using an .env file
docker run --rm --env-file .env -p 3000:3000 --name realworld-app realworld-app:latest

# Or passing critical env directly (replace values):
docker run --rm -e DATABASE_URL="postgresql://user:pass@db:5432/dbname" -p 3000:3000 --name realworld-app realworld-app:latest
```

Notes:
- The app listens on port 3000 by default; change `-p` mapping if needed.
- Provide any required environment variables (database URL, JWT secrets, etc.) via an `.env` file or `-e` flags.
- If you need to run the database locally for the container, either use Docker Compose or run a DB container and link them appropriately.

---

## SonarQube — Analysis Steps

Two common approaches are shown: run SonarQube locally (Docker) + sonar-scanner, or use an installed scanner (npm) from the host.

### 1) Start SonarQube (local Docker)

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts
```

Open `http://localhost:9000`, log in with the admin account (default `admin` / `admin`) and create a project token (or use an existing one). Save the token — it will be used as `SONAR_TOKEN`.

### 2) Prepare project settings

Create a `sonar-project.properties` at the repository root (example):

```properties
sonar.projectKey=realworld-node-express
sonar.projectName=Node Express RealWorld
sonar.projectVersion=1.0
sonar.sources=src
sonar.tests=tests
sonar.exclusions=**/node_modules/**,tmp/**,build/**,dist/**,**/*.spec.ts
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.sourceEncoding=UTF-8
```

Notes:
- `sonar.sources` should point to your TypeScript/JS source folder(s).
- `sonar.typescript.lcov.reportPaths` points to the LCOV file produced by your test runner.

### 3) Generate test coverage (so Sonar picks up coverage)

Run tests and generate LCOV (project uses Jest):

```bash
npm install
npm test -- --coverage
# LCOV will be under coverage/lcov.info by default
```

### 4A) Run sonar-scanner via Docker

On Windows Docker for Desktop, use `host.docker.internal` to reach `localhost` from containers:

```bash
export SONAR_TOKEN="<your_token>"
docker run --rm \
  -e SONAR_HOST_URL="http://host.docker.internal:9000" \
  -e SONAR_LOGIN="$SONAR_TOKEN" \
  -v "%cd%":/usr/src \
  -w /usr/src \
  sonarsource/sonar-scanner-cli
```

On PowerShell replace `"%cd%"` with `"${PWD}"` or use an interactive shell that expands the path correctly.

### 4B) Run sonar-scanner from host (npm)

Install and run the scanner locally:

```bash
npm install --save-dev sonar-scanner
npx sonar-scanner \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=$SONAR_TOKEN
```

Use the token you created in the SonarQube UI; export it into `SONAR_TOKEN` before running.

---

## CI Integration (brief)

- Add the Sonar scanner step after installing dependencies and running tests with coverage.
- Store the Sonar token in your CI secret store and pass it as `SONAR_TOKEN`.

---

## Example Quick Checklist

- [ ] Create `.env` with required runtime variables
- [ ] Build image: `docker build -t realworld-app:latest .`
- [ ] Run container: `docker run --rm --env-file .env -p 3000:3000 realworld-app:latest`
- [ ] Start SonarQube (if local): `docker run -d --name sonarqube -p 9000:9000 sonarqube:lts`
- [ ] Create Sonar token in UI
- [ ] Run tests with coverage: `npm test -- --coverage`
- [ ] Analyze with sonar-scanner (docker or host)

---

If you want, I can also:
- add a `sonar-project.properties` file to the repo,
- add a CI job snippet for GitHub Actions/GitLab CI,
- or run the analysis locally (if you want me to start the SonarQube container).
# ![Node/Express/Prisma Example App](project-logo.png)

[![Build Status](https://travis-ci.org/anishkny/node-express-realworld-example-app.svg?branch=master)](https://travis-ci.org/anishkny/node-express-realworld-example-app)

> ### Example Node (Express + Prisma) codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld-example-apps) API spec.

<a href="https://thinkster.io/tutorials/node-json-api" target="_blank"><img width="454" src="https://raw.githubusercontent.com/gothinkster/realworld/master/media/learn-btn-hr.png" /></a>

## Getting Started

### Prerequisites

Run the following command to install dependencies:

```shell
npm install
```

### Environment variables

This project depends on some environment variables.
If you are running this project locally, create a `.env` file at the root for these variables.
Your host provider should included a feature to set them there directly to avoid exposing them.

Here are the required ones:

```
DATABASE_URL=
JWT_SECRET=
NODE_ENV=production
```

### Generate your Prisma client

Run the following command to generate the Prisma Client which will include types based on your database schema:

```shell
npx prisma generate
```

### Apply any SQL migration script

Run the following command to create/update your database based on existing sql migration scripts:

```shell
npx prisma migrate deploy
```

### Run the project

Run the following command to run the project:

```shell
npx nx serve api
```

### Seed the database

The project includes a seed script to populate the database:

```shell
npx prisma db seed
```

## Deploy on a remote server

Run the following command to:
- install dependencies
- apply any new migration sql scripts
- run the server

```shell
npm ci && npx prisma migrate deploy && node dist/api/main.js
```
