
#!/usr/bin/env bash
#
# SAMA GIT HISTORY RECONSTRUCTION
#
# Rebuilds the local Git history from timestamped files in development/.
# Creates one commit per timestamp group.
#
# Run from any directory:
#   bash /path/to/development/rebuild_sama_history.sh
#
# No GitHub publication or push is performed.

# set -Eeuo pipefail

# ============================================================
# CONFIGURATION
# ============================================================

EXPECTED_COUNT=23
EXPECTED_GROUPS=20
EXPECTED_BRANCH="main"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DEV_DIR="$SCRIPT_DIR"

COMMIT_COUNT=0
CURRENT_TIMESTAMP="initialization"

declare -A COMMIT_MESSAGES=(
    ["261113_061429"]="Create initial modular function call matrix prototype"
    ["261113_102341"]="Add visible table-cell borders to function matrix"
    ["261113_153428"]="Introduce dark theme for function call matrix"
    ["261113_153914"]="Centralize matrix appearance and geometry in CSS variables"
    ["261113_155921"]="Refine matrix tracks and remove default inspection borders"
    ["261113_183904"]="Build interactive function matrix layout prototype"
    ["261114_165153"]="Add layout presets and interactive calibration controls"
    ["261114_180326"]="Apply measured dimensions to five layout presets"
    ["261114_181345"]="Add initial GHPUtil static analysis data"
    ["261114_183717"]="Connect function matrix viewer to GHPUtil analysis"
    ["261114_185738"]="Refine GHPUtil viewer defaults and presentation"
    ["261115_045717"]="Add external JSON loading and relationship validation"
    ["261115_061737"]="Separate analysis data from viewer implementation"
    ["261115_105938"]="Introduce separate calibration window for viewer adjustments"
    ["261115_112936"]="Improve bidirectional calibration window communication"
    ["261115_113938"]="Improve calibration connectivity and analysis loading fallback"
    ["261115_115215"]="Load analysis through companion JavaScript data file"
    ["261115_120759"]="Use text-extension JavaScript companion for analysis loading"
    ["261115_122509"]="Restore JavaScript companion filename in viewer"
    ["261115_130827"]="Expand calibration presets and generate configurable visual parameters"
)

EXPECTED_FILES=(
    "261113_061429_sama.html"
    "261113_102341_sama.html"
    "261113_153428_sama.html"
    "261113_153914_sama.html"
    "261113_155921_sama.html"
    "261113_183904_sama.html"
    "261114_165153_sama.html"
    "261114_180326_sama.html"
    "261114_181345_sama.json"
    "261114_183717_sama.html"
    "261114_185738_sama.html"
    "261115_045717_sama.html"
    "261115_045717_sama.json"
    "261115_061737_sama.html"
    "261115_061737_sama.js.txt"
    "261115_061737_sama.json"
    "261115_105938_sama.html"
    "261115_112936_sama.html"
    "261115_113938_sama.html"
    "261115_115215_sama.html"
    "261115_120759_sama.html"
    "261115_122509_sama.html"
    "261115_130827_sama.html"
)

declare -A GROUP_FILES=()
GROUP_TIMESTAMPS=()

# ============================================================
# DIAGNOSTICS
# ============================================================

print_error() {
    printf '\nERROR: %s\n' "$*" >&2
}

print_section() {
    printf '\n============================================================\n'
    printf '%s\n' "$*"
    printf '============================================================\n'
}

fatal_error() {
    print_error "$*"
    exit 1
}

unexpected_error() {
    local status="$1"
    local command="$2"
    local line="$3"
    local function_name="${FUNCNAME[1]:-main}"

    print_error "Unexpected failure."
    print_error "Function: $function_name"
    print_error "Line:     $line"
    print_error "Command:  $command"
    print_error "Status:   $status"

    exit "$status"
}

# Report unexpected Bash errors.
trap 'unexpected_error "$?" "$BASH_COMMAND" "$LINENO"' ERR

# ============================================================
# RETRY HANDLING
# ============================================================

run_with_retry() {
    local description="$1"
    shift

    local status
    local attempt=1
    local answer

    while true; do
        printf '\nOperation: %s\n' "$description"

        if "$@"; then
            return 0
        else
            status=$?
        fi

        print_error "Operation failed: $description"
        print_error "Exit status: $status"
        printf 'Attempt: %s\n' "$attempt" >&2

        while true; do
            printf '\n[R]etry operation or [S]top execution? [R/S]: ' >&2
            read -r answer || answer="S"

            case "$answer" in
                r|R|retry|RETRY)
                    attempt=$((attempt + 1))
                    break
                    ;;
                s|S|stop|STOP)
                    print_error "Execution stopped by user."
                    return "$status"
                    ;;
                *)
                    printf 'Please enter R or S.\n' >&2
                    ;;
            esac
        done
    done
}

# ============================================================
# REPOSITORY VALIDATION
# ============================================================

validate_repository() {
    print_section "VALIDATING REPOSITORY"

    git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null ||
        fatal_error "Parent directory is not a Git repository."

    local actual_root
    actual_root="$(git -C "$REPO_ROOT" rev-parse --show-toplevel)"

    [[ "$actual_root" == "$REPO_ROOT" ]] ||
        fatal_error "Unexpected Git repository root."

    local branch
    branch="$(git -C "$REPO_ROOT" branch --show-current)"

    [[ "$branch" == "$EXPECTED_BRANCH" ]] ||
        fatal_error "Expected branch '$EXPECTED_BRANCH'; found '${branch:-detached HEAD}'."

    if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
        git -C "$REPO_ROOT" status --short
        fatal_error "Working tree is not clean. Review existing changes first."
    fi

    git -C "$REPO_ROOT" var GIT_AUTHOR_IDENT >/dev/null ||
        fatal_error "Git author identity is not configured."

    git -C "$REPO_ROOT" var GIT_COMMITTER_IDENT >/dev/null ||
        fatal_error "Git committer identity is not configured."

    git -C "$REPO_ROOT" check-ignore -q -- "$DEV_DIR" ||
        fatal_error "development/ is not ignored by Git."

    printf 'Repository: %s\n' "$REPO_ROOT"
    printf 'Branch:     %s\n' "$branch"
    printf 'Status:     Clean\n'
}

# ============================================================
# SOURCE INVENTORY
# ============================================================

validate_source_inventory() {
    print_section "VALIDATING SOURCE INVENTORY"

    local actual_files=()
    local expected
    local actual
    local found

    while IFS= read -r actual; do
        actual_files+=("$actual")
    done < <(
        find "$DEV_DIR" -maxdepth 1 -type f \
            -regextype posix-extended \
            -regex '.*/[0-9]{6}_[0-9]{6}_sama\.(html|json|js\.txt)' \
            -printf '%f\n' | sort
    )

    [[ "${#actual_files[@]}" -eq "$EXPECTED_COUNT" ]] ||
        fatal_error "Expected $EXPECTED_COUNT files; found ${#actual_files[@]}."

    for expected in "${EXPECTED_FILES[@]}"; do
        found=0

        for actual in "${actual_files[@]}"; do
            if [[ "$actual" == "$expected" ]]; then
                found=1
                break
            fi
        done

        [[ "$found" -eq 1 ]] ||
            fatal_error "Missing source file: $expected"
    done

    for actual in "${actual_files[@]}"; do
        found=0

        for expected in "${EXPECTED_FILES[@]}"; do
            if [[ "$actual" == "$expected" ]]; then
                found=1
                break
            fi
        done

        [[ "$found" -eq 1 ]] ||
            fatal_error "Unexpected source file: $actual"
    done

    printf 'Verified source files: %s\n' "${#actual_files[@]}"
}

# ============================================================
# TIMESTAMP GROUP DISCOVERY
# ============================================================

discover_timestamp_groups() {
    print_section "DISCOVERING TIMESTAMP GROUPS"

    local filename
    local timestamp

    for filename in "${EXPECTED_FILES[@]}"; do
        timestamp="${filename:0:13}"

        if [[ -z "${GROUP_FILES[$timestamp]+present}" ]]; then
            GROUP_TIMESTAMPS+=("$timestamp")
            GROUP_FILES["$timestamp"]=""
        fi

        GROUP_FILES["$timestamp"]+="${filename}"$'\n'
    done

    [[ "${#GROUP_TIMESTAMPS[@]}" -eq "$EXPECTED_GROUPS" ]] ||
        fatal_error "Expected $EXPECTED_GROUPS groups; found ${#GROUP_TIMESTAMPS[@]}."

    for timestamp in "${GROUP_TIMESTAMPS[@]}"; do
        [[ -n "${COMMIT_MESSAGES[$timestamp]:-}" ]] ||
            fatal_error "Missing commit message for $timestamp"
    done

    printf 'Verified timestamp groups: %s\n' "${#GROUP_TIMESTAMPS[@]}"

    for timestamp in "${GROUP_TIMESTAMPS[@]}"; do
        printf '  %s\n' "$timestamp"
    done
}

# ============================================================
# DESTINATION MAPPING
# ============================================================

get_destination_name() {
    local source_name="$1"

    case "$source_name" in
        *_sama.html)
            printf '%s' "sama.html"
            ;;
        *_sama.json)
            printf '%s' "sama.json"
            ;;
        *_sama.js.txt)
            printf '%s' "sama.js"
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================
# FILE COPYING
# ============================================================

copy_timestamp_group() {
    local timestamp="$1"
    local filename
    local destination
    local source_path
    local destination_path

    print_section "COPYING GROUP $timestamp"

    while IFS= read -r filename; do
        [[ -n "$filename" ]] || continue

        source_path="$DEV_DIR/$filename"

        [[ -f "$source_path" ]] ||
            fatal_error "Source file disappeared: $source_path"

        destination="$(get_destination_name "$filename")" ||
            fatal_error "Cannot map source filename: $filename"

        destination_path="$REPO_ROOT/$destination"

        printf '\nSource:      %s\n' "$filename"
        printf 'Destination: %s\n' "$destination"

        run_with_retry \
            "Copy $filename to $destination" \
            cp -f -- "$source_path" "$destination_path" ||
            return 1

    done <<< "${GROUP_FILES[$timestamp]}"

    return 0
}

# ============================================================
# GIT STAGING
# ============================================================

stage_timestamp_group() {
    local timestamp="$1"
    local filename
    local destination
    local destinations=()

    print_section "STAGING GROUP $timestamp"

    while IFS= read -r filename; do
        [[ -n "$filename" ]] || continue

        destination="$(get_destination_name "$filename")" ||
            fatal_error "Cannot map source filename: $filename"

        destinations+=("$destination")
    done <<< "${GROUP_FILES[$timestamp]}"

    run_with_retry \
        "Stage files for $timestamp" \
        git -C "$REPO_ROOT" add -- "${destinations[@]}" ||
        return 1

    if git -C "$REPO_ROOT" diff --cached --quiet; then
        fatal_error "No staged changes for timestamp $timestamp."
    fi

    printf '\nStaged changes:\n'
    git -C "$REPO_ROOT" diff --cached --stat

    return 0
}

# ============================================================
# GIT COMMIT
# ============================================================

commit_timestamp_group() {
    local timestamp="$1"
    local message="${COMMIT_MESSAGES[$timestamp]}"

    print_section "COMMITTING GROUP $timestamp"

    printf 'Commit message:\n%s\n' "$message"

    run_with_retry \
        "Create commit for $timestamp" \
        git -C "$REPO_ROOT" commit -m "$message" ||
        return 1

    COMMIT_COUNT=$((COMMIT_COUNT + 1))

    printf '\nCompleted commits: %s / %s\n' \
        "$COMMIT_COUNT" "$EXPECTED_GROUPS"

    return 0
}

# ============================================================
# PROCESS ONE TIMESTAMP GROUP
# ============================================================

process_timestamp_group() {
    local timestamp="$1"

    CURRENT_TIMESTAMP="$timestamp"

    copy_timestamp_group "$timestamp" ||
        return 1

    stage_timestamp_group "$timestamp" ||
        return 1

    commit_timestamp_group "$timestamp" ||
        return 1

    return 0
}

# ============================================================
# PROCESS ALL GROUPS
# ============================================================

process_all_groups() {
    local timestamp

    for timestamp in "${GROUP_TIMESTAMPS[@]}"; do
        if ! process_timestamp_group "$timestamp"; then
            print_error "Stopped while processing $timestamp."
            print_error "Completed commits remain in local Git history."
            return 1
        fi
    done

    return 0
}

# ============================================================
# FINAL REPORT
# ============================================================

show_final_report() {
    print_section "RECONSTRUCTION COMPLETE"

    printf 'Commits created: %s / %s\n' \
        "$COMMIT_COUNT" "$EXPECTED_GROUPS"

    printf '\nRecent Git history:\n'

    git -C "$REPO_ROOT" --no-pager log \
        --oneline \
        --decorate \
        -n "$((EXPECTED_GROUPS + 5))"

    printf '\nWorking-tree status:\n'
    git -C "$REPO_ROOT" status --short

    printf '\nPublication: NOT PERFORMED\n'
    printf 'Repository:  %s\n' "$REPO_ROOT"
}

# ============================================================
# MAIN
# ============================================================

main() {
    print_section "SAMA GIT HISTORY RECONSTRUCTION"

    validate_repository
    validate_source_inventory
    discover_timestamp_groups

    printf '\nRepository: %s\n' "$REPO_ROOT"
    printf 'Source files: %s\n' "$EXPECTED_COUNT"
    printf 'Commit groups: %s\n' "$EXPECTED_GROUPS"

    printf '\nThe script will replace root-level SAMA files.\n'
    printf 'Timestamped source files will remain untouched.\n'
    printf 'No publication will be performed.\n'

    local answer

    printf '\nProceed with local commits? [y/N]: '
    read -r answer || answer="N"

    case "$answer" in
        y|Y|yes|YES)
            ;;
        *)
            printf '\nCancelled. No files were changed.\n'
            return 0
            ;;
    esac

    process_all_groups || return 1

    show_final_report

    return 0
}

# ============================================================
# EXECUTION ENTRY POINT
# ============================================================

# Enable command tracing for the entire execution.
set -x

EXIT_STATUS=0

# <<-'#--fin'
if main; then
    EXIT_STATUS=0
else
    EXIT_STATUS=$?
fi

# Disable command tracing.
set +x

printf '\nScript exit status: %s\n' "$EXIT_STATUS"

if [[ "$EXIT_STATUS" -ne 0 ]]; then
    printf 'Execution did not complete successfully.\n' >&2
fi

# Keep the terminal available for inspection.
printf '\nPress Enter to close this script...'
read -r _ || true

exit "$EXIT_STATUS"
#--fin

declare -p \
SCRIPT_DIR \
;
