# 22holes Backlog

This backlog is machine- and human-readable to allow any AI agent or engineer to pick up work.

## Epics & Milestones

- Foundations & infra
- Core shared models & services
- Minimal iOS app + Map integration
- Watch app & sync
- Course data & autohole detection
- Yardage detail & hazards
- Shot tracking, scorecard, rounds
- Plays-Like & club recommendation
- Premium features & offline maps
- Polish, performance, telemetry
- App Store readiness

## Sprint 1 - Core shared models & services (High priority)

Tasks (atomic):
1.1 - Add SwiftData models: Course, Hole, Tee, Yardage, Hazard, Round, Shot, Club, ClubBag.
  - Required fields: id (UUID), name, coordinate (lat/lon), par, holeIndex, yardages (front/mid/back), hazards (type, coordinate), elevationMeters
  - Relationships: Course -> Hole (1..*), Hole -> Yardage/Hazard
1.2 - PersistenceController: persistent container, in-memory option for tests & previews
1.3 - LocationManager actor (already added) unit tests for lastLocation behavior
1.4 - DistanceCalculator + PlaysLikeCalculator stub (unit tests)

## Sprint 2..10 (see roadmap in README)

## How to pick work (for AI agent)
- Claim an issue by creating a branch feature/<ticket>-short-desc
- Keep PRs small and focused (one logical change)
- Add tests for all service/model changes
- Run `swift test` and ensure CI passes before merging

## Repo conventions
- Branches: main (protected), develop (daily), feature/*, fix/*, test/*
- Commit messages: Conventional Commits (feat:, fix:, chore:, test:)
- PRs: target develop; include screenshots/tests/README updates

---

Generated on: 2025-12-03
