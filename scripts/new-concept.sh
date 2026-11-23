#!/usr/bin/env bash
# Create a new concept repo on GitHub and add it to cpp-maxxing as a submodule.
# Usage: ./scripts/new-concept.sh <concept-name> [--public]
set -euo pipefail

name="${1:?usage: $0 <concept-name> [--public]}"
visibility="--private"
[[ "${2:-}" == "--public" ]] && visibility="--public"

root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
repo="cpp-maxxing-${name}"
owner="$(gh api user --jq .login)"

if [[ -e "$root/$name" ]]; then
  echo "error: $root/$name already exists" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/src" "$tmp/tests"
cat > "$tmp/CMakeLists.txt" <<EOF
cmake_minimum_required(VERSION 3.20)
project(${name//-/_} CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(${name//-/_}_tests tests/main.cpp)
target_include_directories(${name//-/_}_tests PRIVATE src)
target_compile_options(${name//-/_}_tests PRIVATE -Wall -Wextra -Wpedantic)

enable_testing()
add_test(NAME ${name//-/_}_tests COMMAND ${name//-/_}_tests)
EOF

cat > "$tmp/tests/main.cpp" <<'EOF'
#include <cassert>
#include <iostream>

int main() {
    std::cout << "all tests passed\n";
}
EOF

cat > "$tmp/.gitignore" <<'EOF'
build/
.cache/
compile_commands.json
EOF

cat > "$tmp/README.md" <<EOF
# ${name}

A from-scratch recreation of \`${name}\`. Part of [cpp-maxxing](https://github.com/${owner}/cpp-maxxing).

\`\`\`sh
cmake -S . -B build && cmake --build build && ctest --test-dir build
\`\`\`
EOF

git -C "$tmp" init -q -b main
git -C "$tmp" add -A
git -C "$tmp" commit -q -m "Initial skeleton for ${name}"

gh repo create "${owner}/${repo}" "$visibility" --source "$tmp" --push

cd "$root"
git submodule add "https://github.com/${owner}/${repo}.git" "$name"
echo "Added ${name}/ as a submodule. Update the README table and commit."
