#!/bin/bash

set -x
BUILD=false
WORKDIR=/nfs/site/disks/pac_release_1/github/psgpac/altera-fpga/applications.fpga.system-example-designs.agilex5-ed-ethernet/repo_check
# Hardcoded .bb file paths - adjust these to your repo structure
kernel_bb_file=$WORKDIR/src/sw/yocto/meta-agilex5-sed/recipes-kernel/linux/linux-socfpga-lts_%.bbappend
bb_files=(
  "$WORKDIR/src/sw/yocto/meta-agilex5-sed/recipes-devtools/ptpbridge/ptpbridge_1.1.bb"
  "$WORKDIR/src/sw/yocto/meta-agilex5-sed/recipes-devtools/packetgenerator/packetgenerator_1.1.bb"
)

for bbfile in "${bb_files[@]}"; do
  echo "Parsing $bbfile"

  grep '^SRC_URI' "$bbfile" | while read -r line; do
    repo_url=$(echo "$line" | sed -E 's/SRC_URI = "([^;"]+).*/\1/')
    repo_url=${repo_url/#git:/https:}
    branch=$(echo "$line" | grep -oP '(?<=branch=)[^";]+' || echo "main")

    echo "Checking repo: $repo_url branch: $branch"
    rm -rf tmp_repo
    git clone --depth=50 --branch "$branch" "$repo_url" tmp_repo || {
      echo "Failed to clone $repo_url"
      continue
    }
    cd tmp_repo
    commit_count=$(git log --since="1 day ago" --oneline | wc -l)
    cd ..

    if [ "$commit_count" -gt 0 ]; then
      echo "Repo $repo_url (branch $branch) has $commit_count new commits"
      BUILD=true
      break 1  # Exit both loops early since we found a change
    else
      echo "No new commits in last day for $repo_url (branch $branch)"
    fi
  done
done

if [ "$BUILD" != "true" ]; then
  KERNEL_REPO=$(grep '^KERNEL_REPO' $kernel_bb_file | sed -E 's/.*= *"([^"]+)".*/\1/')
  kernel_repo_url=${KERNEL_REPO/#git:/https:}
  KBRANCH=$(grep '^KBRANCH' $kernel_bb_file | sed -E 's/.*= *"([^"]+)".*/\1/')
  echo "Checking repo: $kernel_repo_url branch: $KBRANCH"
  rm -rf tmp_repo
  git clone --depth=50 --branch "$KBRANCH" "$kernel_repo_url" tmp_repo
  cd tmp_repo
  commit_count=$(git log --since="1 day ago" --oneline | wc -l)
  cd ..
  if [ "$commit_count" -gt 0 ]; then
      echo "Repo $kernel_repo_url (branch $KBRANCH) has $commit_count new commits"
      BUILD=true
  else
      echo "No new commits in last day for $kernel_repo_url (branch $KBRANCH)"
  fi
fi
rm -rf $WORKDIR
echo "BUILD=$BUILD"
echo $BUILD


