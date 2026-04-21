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

ROOT_REAL="$(realpath "$ROOT_DIR")"
WORK_REAL="$(realpath -m "$WORK_DIR")"
OUT_REAL="$(realpath -m "$OUT_DIR")"

if [[ -z "$WORK_REAL" || -z "$OUT_REAL" || "$WORK_REAL" == "/" || "$OUT_REAL" == "/" ]]; then
  echo "Refusing to remove unsafe build directories" >&2
  exit 1
fi

if [[ "$WORK_REAL" != "$ROOT_REAL/"* || "$OUT_REAL" != "$ROOT_REAL/"* ]]; then
  echo "Build directories must be inside repository root" >&2
  exit 1
fi

rm -rf "$WORK_REAL" "$OUT_REAL"
mkdir -p "$WORK_REAL" "$OUT_REAL"

WORK_DIR="$WORK_REAL"
OUT_DIR="$OUT_REAL"

for repo_path in "${REPOSITORIES[@]}"; do
  language_name="${repo_path##*/}"
  language_name="${language_name#tree-sitter-}"

  echo "Building $repo_path -> $language_name"

  repo_dir="$WORK_DIR/$language_name"
  package_dir="$WORK_DIR/package-$language_name"

  if ! git clone --depth 1 "https://github.com/${repo_path}.git" "$repo_dir"; then
    echo "Failed to clone repository $repo_path" >&2
    exit 1
  fi

  pushd "$repo_dir" >/dev/null
  echo "Building wasm parser for $language_name"
  if ! tree-sitter build --wasm; then
    echo "Failed to build wasm parser for $language_name ($repo_path)" >&2
    exit 1
  fi

  mapfile -t wasm_files < <(find . -maxdepth 2 -type f -name '*.wasm' -print)
  if [[ "${#wasm_files[@]}" -ne 1 ]]; then
    wasm_details="<none>"
    if [[ "${#wasm_files[@]}" -gt 0 ]]; then
      wasm_details="${wasm_files[*]}"
    fi
    echo "Expected exactly one wasm file for $language_name ($repo_path), found ${#wasm_files[@]}: $wasm_details" >&2
    exit 1
  fi
  wasm_file="${wasm_files[0]}"
  wasm_file_name="$(basename "$wasm_file")"

  mkdir -p "$package_dir"
  cp "$wasm_file" "$package_dir/$wasm_file_name"

  if [[ -d queries ]]; then
    cp -R queries "$package_dir/"
  fi

  if [[ -d "$package_dir/queries" ]]; then
    (cd "$package_dir" && tar czf "$OUT_DIR/${language_name}.tar.gz" "$wasm_file_name" queries)
  else
    (cd "$package_dir" && tar czf "$OUT_DIR/${language_name}.tar.gz" "$wasm_file_name")
  fi
  popd >/dev/null
done
