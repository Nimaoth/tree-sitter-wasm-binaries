#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$ROOT_DIR/.build"
OUT_DIR="$ROOT_DIR/artifacts"

chmod +x "$ROOT_DIR/tree-sitter-cli/tree-sitter"

if [[ -n "${TREE_SITTER_REPOSITORIES:-}" ]]; then
  read -r -a REPOSITORIES <<<"$TREE_SITTER_REPOSITORIES"
else
  REPOSITORIES=(
    "tree-sitter-grammars/tree-sitter-commonlisp"
    "tree-sitter-grammars/tree-sitter-markdown/tree-sitter-markdown"
    "tree-sitter-grammars/tree-sitter-markdown/tree-sitter-markdown-inline"
    "tree-sitter-grammars/tree-sitter-query"
    "tree-sitter-grammars/tree-sitter-toml"
    "tree-sitter-grammars/tree-sitter-xml/xml"
    "tree-sitter-grammars/tree-sitter-yaml"

    "tree-sitter/tree-sitter-agda"
    "tree-sitter/tree-sitter-bash"
    "tree-sitter/tree-sitter-c"
    "tree-sitter/tree-sitter-c-sharp"
    "tree-sitter/tree-sitter-cpp"
    "tree-sitter/tree-sitter-css"
    "tree-sitter/tree-sitter-go"
    "tree-sitter/tree-sitter-haskell"
    "tree-sitter/tree-sitter-html"
    "tree-sitter/tree-sitter-java"
    "tree-sitter/tree-sitter-javascript"
    "tree-sitter/tree-sitter-jsdoc"
    "tree-sitter/tree-sitter-json"
    "tree-sitter/tree-sitter-python"
    "tree-sitter/tree-sitter-ql"
    "tree-sitter/tree-sitter-regex"
    "tree-sitter/tree-sitter-ruby"
    "tree-sitter/tree-sitter-rust"
    "tree-sitter/tree-sitter-scala"

    "Tudyx/tree-sitter-log"
    "Wilfred/tree-sitter-elisp"
    "airbus-cert/tree-sitter-powershell"
    "alaviss/tree-sitter-nim"
    "ap29600/tree-sitter-odin"
    "dehorsley/tree-sitter-angelscript"
    "fwcd/tree-sitter-kotlin"
    "gleam-lang/tree-sitter-gleam"
    "liamwh/tree-sitter-wit"
    "maxxnino/tree-sitter-zig"
    "nix-community/tree-sitter-nix"
    "tjdevries/tree-sitter-lua"
    "wenkokke/tree-sitter-talon"

    # "tree-sitter-grammars/tree-sitter-hcl"
    # "tree-sitter-grammars/tree-sitter-lua"

    # "tree-sitter/tree-sitter-embedded-template"
    # "tree-sitter/tree-sitter-graph"
    # "tree-sitter/tree-sitter-julia"
    # "tree-sitter/tree-sitter-php"
    # "tree-sitter/tree-sitter-regex"
    # "tree-sitter/tree-sitter-verilog"

    # "tree-sitter-perl/tree-sitter-perl"
    # "AndroidIDEOfficial/android-tree-sitter"
    # "Azganoth/tree-sitter-lua"
    # "DerekStride/tree-sitter-sql"
    # "EmranMR/tree-sitter-blade"
    # "IBM/tree-sitter-codeviews"
    # "Isopod/tree-sitter-pascal"
    # "JoranHonig/tree-sitter-solidity"
    # "PrestonKnopp/tree-sitter-gdscript"
    # "UserNobody14/tree-sitter-dart"
    # "WhatsApp/tree-sitter-erlang"
    # "aheber/tree-sitter-sfapex"
    # "airbus-cert/tree-sitter-powershell"
    # "alex-pinkus/tree-sitter-swift"
    # "bonede/tree-sitter-ng"
    # "c3lang/tree-sitter-c3"
    # "camdencheek/tree-sitter-dockerfile"
    # "casey/tree-sitter-just"
    # "casouri/tree-sitter-module"
    # "elixir-lang/tree-sitter-elixir"
    # "elm-tooling/tree-sitter-elm"
    # "emacs-tree-sitter/elisp-tree-sitter"
    # "emacs-tree-sitter/tree-sitter-langs"
    # "emiasims/tree-sitter-org"
    # "faldor20/tree-sitter-roc"
    # "fwcd/tree-sitter-kotlin"
    # "georgewfraser/vscode-tree-sitter"
    # "gleam-lang/tree-sitter-gleam"
    # "grantjenks/py-tree-sitter-languages"
    # "ikatyang/tree-sitter-markdown"
    # "ikatyang/tree-sitter-toml"
    # "ikatyang/tree-sitter-vue"
    # "ikatyang/tree-sitter-yaml"
    # "ionide/tree-sitter-fsharp"
    # "kreuzberg-dev/tree-sitter-language-pack"
    # "latex-lsp/tree-sitter-latex"
    # "legesher/tree-sitter-legesher-python"
    # "m-novikov/tree-sitter-sql"
    # "maxxnino/tree-sitter-zig"
    # "meain/evil-textobj-tree-sitter"
    # "mitchellh/tree-sitter-proto"
    # "neovim/tree-sitter-vimdoc"
    # "neurocyte/tree-sitter"
    # "ngalaiko/tree-sitter-go-template"
    # "nix-community/tree-sitter-nix"
    # "nushell/tree-sitter-nu"
    # "nvim-neorg/tree-sitter-norg"
    # "phoenixframework/tree-sitter-heex"
    # "r-lib/tree-sitter-r"
    # "rescript-lang/tree-sitter-rescript"
    # "rest-nvim/tree-sitter-http"
    # "romus204/tree-sitter-manager.nvim"
    # "serenadeai/java-tree-sitter"
    # "serenadeai/tree-sitter-scss"
    # "simonbs/TreeSitterLanguages"
    # "smacker/go-tree-sitter"
    # "sogaiu/tree-sitter-clojure"
    # "stadelmanma/tree-sitter-fortran"
    # "stsewd/tree-sitter-comment"
    # "uben0/tree-sitter-typst"
    # "vigoux/tree-sitter-viml"
    # "vrischmann/tree-sitter-templ"
    # "wrale/mcp-server-tree-sitter"

    # "tree-sitter/tree-sitter-typescript/typescript"
    # "tree-sitter/tree-sitter-typescript/tsx"

    # "tree-sitter/tree-sitter-ocaml/grammars/interface"
    # "tree-sitter/tree-sitter-ocaml/grammars/ocaml"
    # "tree-sitter/tree-sitter-ocaml/grammars/type"
    # "tree-sitter/tree-sitter-php/php"
    # "tree-sitter/tree-sitter-php/php_only"
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

rm -rf "$OUT_REAL"
mkdir -p "$WORK_REAL" "$OUT_REAL"

WORK_DIR="$WORK_REAL"
OUT_DIR="$OUT_REAL"

for entry in "${REPOSITORIES[@]}"; do
  # entry is org/repo  or  org/repo/subfolder
  IFS='/' read -ra parts <<<"$entry"
  repo_org="${parts[0]}"
  repo_name="${parts[1]}"
  repo_subdir="${parts[2]:-}"

  repo_gh_path="$repo_org/$repo_name"

  # language name is derived from the last path component
  language_name="${entry##*/}"
  language_name="${language_name#tree-sitter-}"

  echo "Building $entry -> $language_name"

  repo_dir="$WORK_DIR/$repo_name"
  package_dir="$WORK_DIR/package-$language_name"

  if [[ -d "$repo_dir/.git" ]]; then
    echo "Updating existing clone of $repo_gh_path"
    if ! git -C "$repo_dir" pull; then
      echo "Failed to update repository $repo_gh_path" >&2
      exit 1
    fi
  else
    if ! git clone --depth 1 "https://github.com/${repo_gh_path}.git" "$repo_dir"; then
      echo "Failed to clone repository $repo_gh_path" >&2
      exit 1
    fi
  fi

  if [[ -n "$repo_subdir" ]]; then
    build_dir="$repo_dir/$repo_subdir"
  else
    build_dir="$repo_dir"
  fi

  pushd "$build_dir" >/dev/null
  echo "Building wasm parser for $language_name"
  if ! "$ROOT_DIR/tree-sitter-cli/tree-sitter" build --wasm; then
    echo "Failed to build wasm parser for $language_name ($entry)" >&2
    exit 1
  fi

  mapfile -t wasm_files < <(find . -maxdepth 2 -type f -name '*.wasm' -print)
  if [[ "${#wasm_files[@]}" -ne 1 ]]; then
    wasm_details="<none>"
    if [[ "${#wasm_files[@]}" -gt 0 ]]; then
      wasm_details="${wasm_files[*]}"
    fi
    echo "Expected exactly one wasm file for $language_name ($entry), found ${#wasm_files[@]}: $wasm_details" >&2
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
