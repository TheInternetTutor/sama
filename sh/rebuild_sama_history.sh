#!/usr/bin/env bash
# Rename the 18 non-directive files from the SAMA Legacy inventory.
# Dry run is the default. Pass --apply to perform the renames.
# Timestamp source: the previously established Library created_at inventory,
# converted to US Eastern time (EST, UTC-5).

set -u

usage() {
    printf 'Usage: %s [--apply]\n' "${0##*/}"
    printf 'Default: dry run. Use --apply to rename files.\n'
}

apply=0
case "${1-}" in
    "") ;;
    --apply) apply=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

# Operate only in the directory containing this script.
script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
cd -- "$script_dir" || exit 1

if (( apply )); then
    printf 'MODE: APPLY\nDirectory: %s\n\n' "$PWD"
else
    printf 'MODE: DRY RUN (no files will be changed)\nDirectory: %s\n\n' "$PWD"
fi

renamed=0
missing=0
conflicts=0

while IFS=$'\t' read -r source target; do
    [[ -z "$source" ]] && continue

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        printf 'MISSING : %s\n' "$source"
        ((missing += 1))
        continue
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        printf 'CONFLICT: %s -> %s (destination already exists)\n' "$source" "$target"
        ((conflicts += 1))
        continue
    fi

    if (( apply )); then
        if mv -- "$source" "$target"; then
            printf 'RENAMED : %s -> %s\n' "$source" "$target"
            ((renamed += 1))
        else
            printf 'ERROR   : %s -> %s\n' "$source" "$target" >&2
            ((conflicts += 1))
        fi
    else
        printf 'WOULD   : %s -> %s\n' "$source" "$target"
        ((renamed += 1))
    fi
done <<'RENAME_MAP'
modular_function_call_matrix.html	261113_061429_sama.html
image(1).png	261113_090547_sama.png
modular_function_call_diagrams_handover.md	261113_090840_sama.md
modular_function_call_matrix_borders(1).html	261113_102341_sama.html
modular_function_call_matrix_configurable(2).html	261113_103927_sama.html
image(2).png	261113_111737_sama.png
modular_function_call_matrix_refined(1).html	261113_133947_sama.html
modular_function_call_matrix_ghputil.html	261114_131443_sama.html
image(2)(1).png	261114_165300_sama.png
image(3).png	261114_165359_sama.png
Self-Recursion Function Tracks.png	261114_181328_sama.png
modular_function_call_matrix_ghputil(5).html	261115_051636_sama.html
ghputil_static_analysis.js	261115_065242_sama.js.txt
ghputil_static_analysis(7).json	261115_065244_sama.json
ghputil_static_analysis_pretty.js	261115_065809_sama.js.txt
ghputil_static_analysis_pretty.js.txt	261115_070102_sama.js.txt
modular_function_call_matrix_ghputil(20261115-233941).html	261115_122509_sama.html
sama_modular_directives.zip	261115_174444_sama.zip
RENAME_MAP

printf '\nSummary: %d %s, %d missing, %d conflicts.\n' \
    "$renamed" "$([[ $apply -eq 1 ]] && printf 'renamed' || printf 'planned')" \
    "$missing" "$conflicts"

if (( ! apply )); then
    printf 'No changes made. Re-run with --apply to execute the plan.\n'
fi

(( conflicts == 0 ))
