# precommit.vim

`precommit.vim` is a standalone Vim plugin scaffold for running
[`pre-commit`](https://pre-commit.com/) from Vim with quickfix output and
dynamic hook completion sourced from `.pre-commit-config.yaml`.

## Layout

```text
vim-precommit-plugin/
├── autoload/precommit.vim
├── compiler/pre_commit.vim
├── doc/precommit.txt
├── plugin/precommit.vim
├── test/precommit.vader
├── test/run-tests.sh
├── test/vimrc
├── LICENSE
└── README.md
```

## Features

- `:PreCommit [args]` for raw `pre-commit` subcommands
- `:PreCommitHook {hook}` with hook completion from the local config
- `:PreCommitAll [hook]` for `--all-files` runs
- `:PreCommitFile [hook]` for current-buffer runs
- `:PreCommitInstall`, `:PreCommitUpdate`, and `:PreCommitClean`
- Quickfix population for captured output
- Bundled `:compiler pre_commit` profile

## Installation

Copy `vim-precommit-plugin` into your plugin manager or runtime path.

Examples:

- `~/.vim/pack/vendor/start/vim-precommit-plugin`
- `~/.vim/bundle/vim-precommit-plugin`

Then generate help tags:

```vim
:helptags ~/.vim/pack/vendor/start/vim-precommit-plugin/doc
```

## Usage

```vim
:PreCommitInstall
:PreCommitHook trailing-whitespace
:PreCommitAll
:PreCommitFile end-of-file-fixer
:PreCommit run --all-files
```

The hook-aware commands read hook ids from the nearest
`.pre-commit-config.yaml` or `.pre-commit-config.yml` found above the current
buffer.

## Configuration

```vim
let g:precommit_command = 'pre-commit'
let g:precommit_open_qf = 1
```

`g:precommit_command` lets you point to a virtualenv-specific binary if needed.
The bundled `:compiler pre_commit` profile uses the same setting for `makeprg`.

## Testing

The scaffold includes a Vader suite covering command registration, hook
discovery/completion, config root detection, and quickfix population.

Run it with a local `vader.vim` checkout:

```bash
VADER_DIR=/path/to/vader.vim ./test/run-tests.sh
```

## Attribution and references

This plugin is an integration layer for external hook runners and depends on
having one available on your system.

- [`pre-commit`](https://pre-commit.com/) is the default runtime dependency.
  The plugin's commands, config discovery, and examples are primarily built
  around the `pre-commit` CLI and `.pre-commit-config.yaml`.
- [`prek`](https://prek.j178.dev/) is a relevant supporting reference because
  it is a Rust reimplementation intended as a drop-in alternative for
  `pre-commit`. You can use it with this plugin by setting:

```vim
let g:precommit_command = 'prek'
```

See the upstream project documentation for installation, command/reference
details, and compatibility notes:

- <https://pre-commit.com/>
- <https://prek.j178.dev/>
