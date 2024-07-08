#!/bin/bash
#
# This script prints a table of all remote branches with the following columns:
# - Branch name
# - Last updated
# - Status checks
# - Behind|Ahead
#
# depends on the github cli

if [ ! -d ".git" ]; then
    echo "Not a Git repository."
    exit 1
fi

gh_cli_available=false
if command -v gh &> /dev/null; then
    gh_cli_available=true
fi

remotes=$(git remote -v)
is_github=false
if echo "$remotes" | grep -q "github.com"; then
    is_github=true
fi

repo=$(git config --get remote.origin.url | awk -F/ '{print $(NF-0)}' \
    | sed 's/\.git$//')

owner=$(git config --get remote.origin.url | awk -F/ '{print $(NF-1)}')

curr_branch=$(git branch --show-current)

# Set headers for each column
name_header="Branch Name"
last_updated_header="Last Updated"
status_checks_header="Status Checks"
behind_ahead_header="Behind Ahead Remote"

# Initialize variables to store max lengths for each column
max_branch_length=${#name_header}
max_last_updated_length=${#last_updated_header}
max_status_checks_length=${#status_checks_header}
max_behind_ahead_length=${#behind_ahead_header}

# TODO : the script is slow-ish right now, either optimize the status info
# retrieval or toggle it with an option
status_check_info=""
num_workflows=0
if [ $gh_cli_available = true ] && [ $is_github = true ]; then
    status_check_info=$(gh api \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            /repos/$owner/$repo/actions/runs?exclude_pull_requests=true)

    # Get the total number of unique workflows
    # TODO : counts matrix workflows as 1 which the github ui does not
    num_workflows=$(echo "$status_check_info" | jq \
        '.workflow_runs | map(.workflow_id) | unique | length')
fi

# Function to print a table row
echo_row() {
    col1=$(pad_string "$1" $max_branch_length)
    col2=$(pad_string "$2" $max_last_updated_length)
    col3=$(pad_string "$3" $max_status_checks_length)
    col4=$(pad_string "$4" $max_behind_ahead_length)
    echo "$col1 | $col2 | $col3 | $col4"
}

# Function to update max length variables
update_max_lengths() {
    if [[ ${#branch_name} -gt $max_branch_length ]]; then
        max_branch_length=${#branch_name}
    fi
    if [[ ${#last_commit_date} -gt $max_last_updated_length ]]; then
        max_last_updated_length=${#last_commit_date}
    fi
    if [[ ${#status_checks} -gt $max_status_checks_length ]]; then
        max_status_checks_length=${#status_checks}
    fi
    if [[ ${#behind_ahead} -gt $max_behind_ahead_length ]]; then
        max_behind_ahead_length=${#behind_ahead}
    fi
}

# Function to pad strings with spaces to align columns
pad_string() {
    local str=$1
    local length=$2
    printf "%-${length}s" "$str"
}

# Function to extract the number of successful status checks for a branch
get_branch_check_succ_cnt() {
    branch=$1
    fail_count=$(echo "$status_check_info" | jq --arg branch "$branch" \
        '.workflow_runs 
            | map(select(.head_branch == $branch)) 
            | unique_by(.workflow_id) 
            | map(select(.conclusion == "failure")) 
            | length')
    
    succ_cnt=$((num_workflows - fail_count))
    echo "$succ_cnt/$num_workflows"
}

# Get max lengths for each column and store entries
names=()
dates=()
checks=()
behinds_aheads=()
while read -r ref upstream; do
    # Only get status checks for remote branches
    branch="${ref#refs/heads/}"
    status_checks=("N/A")
    if [ ! -z "$upstream" ] && [ ! -z "$status_check_info" ]; then
        status_checks=$(get_branch_check_succ_cnt $branch)
    fi
   
    last_commit_msg=$(git log $branch -1 --pretty=%B)
    last_commit_date="$(git log -1 --format="%cr" $branch) : $last_commit_msg"
    h=$(git rev-parse HEAD)
    behind_ahead=$(git rev-list --left-right --count HEAD...$branch)
    
    # Mark the current branch with an *
    branch_name="$branch [$upstream]"
    if [[ $branch == $curr_branch ]]; then
        branch_name="* $branch_name"
    fi

    dates+=("$last_commit_date")
    checks+=("$status_checks")
    behinds_aheads+=("$behind_ahead")
    names+=("$branch_name")

    update_max_lengths
done < <(git branch -vv --format '%(refname) %(upstream)')

# Print header row
echo_row "$name_header" "$last_updated_header" "$status_checks_header" \
    "$behind_ahead_header"

# Print branch details
for i in "${!names[@]}"; do
    branch_name=${names[$i]}
    last_commit_date=${dates[$i]}
    status_checks=${checks[$i]}
    behind_ahead=${behinds_aheads[$i]}

    echo_row "$branch_name" "$last_commit_date" "$status_checks" \
        "$behind_ahead"
done
