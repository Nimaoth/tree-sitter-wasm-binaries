#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$ROOT_DIR/.build"
OUT_DIR="$ROOT_DIR/artifacts"

if [[ -n "${TREE_SITTER_REPOSITORIES:-}" ]]; then
  read -r -a REPOSITORIES <<<"$TREE_SITTER_REPOSITORIES"
else
  REPOSITORIES=(
    "tree-sitter/tree-sitter-bash"
    "tree-sitter/tree-sitter-c"
    "tree-sitter/tree-sitter-cpp"
    "tree-sitter/tree-sitter-javascript"
    "tree-sitter/tree-sitter-json"
    "tree-sitter/tree-sitter-python"
    "tree-sitter/tree-sitter-rust"
    "tree-sitter/tree-sitter-typescript"
  )
fi

rm -rf "$WORK_DIR" "$OUT_DIR"
mkdir -p "$WORK_DIR" "$OUT_DIR"

for repo_path in "${REPOSITORIES[@]}"; do
  language_name="${repo_path##*/}"
  language_name="${language_name#tree-sitter-}"

  echo "Building $repo_path -> $language_name"

  repo_dir="$WORK_DIR/$language_name"
  package_dir="$WORK_DIR/package-$language_name"

  git clone --depth 1 "https://github.com/${repo_path}.git" "$repo_dir"

  pushd "$repo_dir" >/dev/null
  tree-sitter build --wasm

  wasm_file="$(find . -maxdepth 2 -type f -name '*.wasm' | head -n 1 || true)"
  if [[ -z "$wasm_file" ]]; then
    echo "No wasm file generated for $language_name ($repo_path)" >&2
    exit 1
  fi

  mkdir -p "$package_dir"
  cp "$wasm_file" "$package_dir/"

  if [[ -d queries ]]; then
    cp -R queries "$package_dir/"
  fi

  (cd "$package_dir" && zip -r "$OUT_DIR/${language_name}.zip" .)
  popd >/dev/null
done
