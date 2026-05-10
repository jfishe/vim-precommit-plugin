# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

## [0.1.1] - 2026-05-10

### Added

- GitHub Actions release workflow for publishing releases from pushed version
  tags.
- Generic `RELEASE_HEAD.md` content for changelog-derived GitHub release notes.

## [0.1.0] - 2026-05-10

### Added

- Initial Vim plugin scaffold for running `pre-commit` from Vim.
- User commands for raw `pre-commit` invocation plus hook-specific, all-files,
  and current-file workflows.
- Dynamic hook completion by scanning `.pre-commit-config.yaml` and
  `.pre-commit-config.yml`.
- Quickfix integration for command output and a `:compiler pre_commit` profile.
- Support for overriding the executable via `g:precommit_command`, including
  compiler `makeprg` integration.
- User documentation, Vim help, attribution/reference notes, and a Vader test
  suite covering command registration, completion, project discovery, and
  quickfix behavior.

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
[Unreleased]: https://github.com/jfishe/vim-precommit-plugin/compare/0.1.1...HEAD
[0.1.1]: https://github.com/jfishe/vim-precommit-plugin/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/jfishe/vim-precommit-plugin/tree/0.1.0
