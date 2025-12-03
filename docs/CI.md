# CI & Snapshot Pipeline

This document explains how CI and snapshot testing are configured for 22holes.

Workflows
- CI (.github/workflows/ci.yml): runs unit/package tests on macos-latest. Caches SPM and DerivedData.
- Snapshots (.github/workflows/snapshots.yml): runs snapshot tests via Fastlane. By default snapshot mismatches will fail the job; set secret SNAPSHOT_FAIL=false to only warn.

Fastlane
- fastlane/ contains lanes for ios_test and screenshots. Do not commit credentials; use environment variables in Actions.

Re-recording snapshots
- Run `./tools/run_snapshots.sh` locally to record new snapshots.
- Commit snapshots to feature branch and open PR. CI will compare and upload diffs.

Secrets
- Add FASTLANE_SESSION, APP_STORE_CONNECT_API_KEY, and SNAPSHOT_FAIL to repository secrets as needed.

Troubleshooting
- If simulators fail in CI, run the Fastlane lane locally with `FASTLANE_SKIP_UPDATE_CHECK=1 bundle exec fastlane ios_test` and inspect logs in fastlane/test_output.
