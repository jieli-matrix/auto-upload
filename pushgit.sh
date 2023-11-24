#!/bin/bash

# Read config.json
github_token=$(jq -r '.github_token' config.json)
username=$(jq -r 'username' config.json)
useremail=$(jq -r 'useremail' config.json) 
repo=$(jq -r 'repo' config.json)
test_html_path=$(jq -r 'test_html_path' config.json)

# Set the repository URL with an authenticated version
repo_url_with_token="https://oauth2:${github_token}@github.com/${username}/${repo}.git"

# Set up local repository
temp_dir=$(mktemp -d)
cd $temp_dir
git init
git remote add origin "${repo_url_with_token}"

# Configure git user
git config user.name "${username}"
git config user.email "${useremail}"

# configure git debug mode
set GIT_TRACE=true
set GIT_CURL_VERBOSE=true
set GIT_SSH_COMMAND=ssh -vvv

# Checkout the repository
git fetch --depth 1 origin master
git checkout master

# Copy the test.html file to the temp directory
cp "${test_html_path}" test.html

# Commit and push the changes
git add test.html
git commit -m "Update test.html"
git push --set-upstream ${repo_url_with_token} master

# Clean up
cd ..
rm -rf $temp_dir