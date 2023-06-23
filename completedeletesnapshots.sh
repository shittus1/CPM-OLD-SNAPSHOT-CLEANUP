#!/bin/bash

# Set the cutoff date (format: YYYY-MM-DD)
CUTOFF_DATE="2022-12-01"

# Set the output file path
OUTPUT_FILE="snapshot_list.txt"

# Retrieve the list of snapshots using the AWS CLI
snapshot_list=$(aws ec2 describe-snapshots --query "Snapshots[?StartTime<'${CUTOFF_DATE}'].SnapshotId" --output text)

# Loop through each snapshot in the list and write to the output file
count=0
while read -r snapshot_id; do
  echo "Deleting snapshot: $snapshot_id"
  aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
  ((count++))
done <<< "$snapshot_list"

# Write snapshot information to the output file
echo "$snapshot_list" > "$OUTPUT_FILE"

echo "Snapshot information has been written to $OUTPUT_FILE."
echo "Total number of snapshots deleted: $count"
