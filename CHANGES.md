# Changes

## v0.1.4

- fix: non-working abnormal script termination in a loop (tl;dr exit from a spawned process for a loop rather than from the script itself)

## v0.1.3

- add: `track-git-ignore` (in `.ensure-ansiblevaulted.yml`) to raise a warning/error when a non-encrypted version of file is not listed in `.gitignore`

## v0.1.2

- fix: error is raised when the config is not available
- fix: hook called only once
- add: `DEBUG` environment variable to trace shell execution (`set -x`)

## v0.1.1 (v0.1.0)

Initial release
