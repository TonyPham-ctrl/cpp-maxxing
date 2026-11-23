# cpp-maxxing

Recreations of C++ concepts from scratch. Each concept lives in its own repository and is
included here as a git submodule.

## Concepts

| Concept | Submodule |
|---------|-----------|
| _none yet_ | |

## Cloning

```sh
git clone --recurse-submodules git@github.com:<you>/cpp-maxxing.git
# or, if already cloned:
git submodule update --init --recursive
```

## Adding a concept

```sh
./scripts/new-concept.sh unique-ptr
```

This creates a GitHub repo `cpp-maxxing-unique-ptr` with a CMake skeleton and adds it as a
submodule at `unique-ptr/`. It needs the [GitHub CLI](https://cli.github.com/) (`gh auth login`).
