---
name: unit-test-writer
description: Use when writing or improving unit tests for new functionality, a bug fix, or a specific function in a service codebase.
---

# Unit Test Writer

Use this skill when unit tests need to be added, updated or designed for service code.

## Main thesis

Write tests that protect behaviour, not implementation details.

## Rules

- Study the local test style first: find the nearest `*_test.*` files in the same package, module or
  directory. Reuse the project's assertion libraries, mock frameworks, fixtures, builders, naming
  style and file layout.
- Identify the externally observable behaviour of the function or feature. Separate behaviour from
  internal implementation details.
- Cover the success path, the important branches, edge cases and error paths. Check empty, zero,
  nil, missing and default inputs when they matter. For batch APIs check partial success and per-item
  errors. For no-op paths check that dependencies are not called.
- Use table-driven tests. Keep every table case readable: move repeated setup into small helpers and
  case-specific setup functions.
- Name cases by behaviour: `returns error when dependency fails`, `skips storage call for empty input`,
  `maps not found to false`.
- Mock everything outside the function and at system boundaries: network, database, cache, queue,
  filesystem, time, randomness, external services, expensive dependencies. Generate mocks if none exist.
  Do not mock internal steps of the function under test.
- Verify dependency calls only when the call is part of the contract or protects an important
  short-circuit / no-op path.
- Assert outcomes first: returned values, errors, persisted state, emitted events, response fields.
- For errors prefer semantic checks: `errors.Is`, typed errors, status codes, or substring checks for
  wrapped context. Don't assert full error text, map iteration order, timestamps, generated IDs or logs
  unless they are the contract.
- Make tests deterministic: control time, randomness, generated IDs, env vars and global config. If
  you change global state, restore it in cleanup hooks. Use parallel tests only when the test does not
  mutate shared process state.
- Don't write mock-heavy tests for metrics or loggers; use an empty metrics namespace and a no-op logger.
- Run the narrowest useful set of tests. Widen the scope when the change touches shared helpers or
  cross-module contracts. If tests cannot be run, state the exact command and the reason.
