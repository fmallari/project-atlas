# Ticket 029 — GitHub Actions CI Pipeline

## Objective

Implement a Continuous Integration (CI) pipeline for Project Atlas using GitHub Actions.

The goal was to automatically validate the application and Docker image on every push or pull request to the `main` branch.

This ticket introduces automated quality gates before future container publishing and deployment workflows.

---

## CI Architecture

```text
Developer
    |
    | git push / pull request
    v
GitHub
    |
    v
GitHub Actions
    |
    +--> Checkout repository
    |
    +--> Set up Python 3.12
    |
    +--> Install dependencies
    |
    +--> Run pytest
    |
    +--> Build Docker image
    |
    v
CI Success
```

---

## Automated Test Setup

Created a development dependency file:

```text
requirements-dev.txt
```

Contents:

```text
-r requirements.txt
pytest==8.4.1
```

This keeps test tooling separate from the production runtime dependencies.

---

## Pytest Configuration

Created:

```text
pytest.ini
```

Configuration:

```ini
[pytest]
pythonpath = .
testpaths = tests
```

This ensures the repository root is available on the Python import path and limits test discovery to the `tests` directory.

---

## Application Tests

Created:

```text
tests/test_app.py
```

The test suite validates the Project Atlas application using the Flask test client.

### Health Endpoint Test

The `/health` endpoint is expected to return:

```json
{
  "status": "healthy",
  "service": "project-atlas",
  "version": "1.0.0"
}
```

The test verifies:

- HTTP status code `200`
- `status == "healthy"`
- `service == "project-atlas"`
- `version == "1.0.0"`

### Homepage Test

The homepage test verifies:

```text
GET /
HTTP 200
```

---

## Local Validation

Before adding the tests to CI, they were executed locally:

```bash
pytest -v
```

Result:

```text
tests/test_app.py::test_health_endpoint PASSED
tests/test_app.py::test_homepage PASSED

2 passed
```

This established a known-good test baseline before moving execution into GitHub Actions.

---

## Docker Validation

The Docker image was also built locally as a CI test:

```bash
docker build -t project-atlas:ci-test .
```

The image build completed successfully.

This validated the same container build step that would later run inside GitHub Actions.

---

## GitHub Actions Workflow

Created:

```text
.github/workflows/ci.yml
```

Workflow:

```yaml
name: Project Atlas CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  test-and-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt

      - name: Run automated tests
        run: pytest -v

      - name: Build Docker image
        run: docker build -t project-atlas:${{ github.sha }} .
```

---

## Trigger Behavior

The workflow runs automatically on:

```text
push → main
pull request → main
```

This means CI validation no longer depends on the developer remembering to run tests or build the Docker image manually.

---

## GitHub Actions Result

After pushing the workflow to GitHub, the CI pipeline triggered automatically.

The workflow completed successfully:

```text
Workflow: Project Atlas CI
Job: test-and-build
Status: Success
```

The job successfully executed:

```text
Checkout repository
        ↓
Set up Python
        ↓
Install dependencies
        ↓
Run automated tests
        ↓
Build Docker image
        ↓
Success
```

---

## Evidence

### GitHub Actions CI Success

![GitHub Actions CI success](screenshots/Ticket-029/github-actions-ci-success.png)

### Test and Build Job Steps

![GitHub Actions test and build steps](screenshots/Ticket-029/github-actions-test-build-steps.png)

---

## Key Takeaways

- Implemented the first CI pipeline for Project Atlas.
- Added automated Flask application tests using pytest.
- Validated the `/health` endpoint contract automatically.
- Added homepage smoke testing.
- Separated development/test dependencies from production dependencies.
- Standardized CI on Python 3.12 to match the Docker runtime.
- Automated Docker image build validation.
- Configured CI to execute automatically on pushes and pull requests to `main`.
- Established automated quality gates before future ECR publishing and deployment.
- Connected local development validation with a repeatable cloud-hosted CI workflow.

---

## Result

Project Atlas now has an automated Continuous Integration pipeline.

The development workflow has progressed from:

```text
Developer
    |
    v
Manual Testing
    |
    v
Manual Docker Build
```

to:

```text
Developer
    |
    | git push
    v
GitHub Actions
    |
    +--> Automated Tests
    |
    +--> Docker Build
    |
    v
CI Success
```

This establishes the foundation for the next phase of Project Atlas:

```text
CI
 |
 v
AWS Authentication
 |
 v
Automated ECR Publishing
 |
 v
Automated Deployment
```
