#!/bin/bash

# Set the threshold in days (export snapshots older than 3 days)
threshold=3

# Get the current date in seconds since epoch
current_date=$(date +%s)

# Create a directory to store the exported snapshots
export_dir="/path/to/export/directory"
mkdir -p "$export_dir"

# Iterate through each snapshot
for snapshot_id in $(aws ec2 describe-snapshots --query 'Snapshots[*].[SnapshotId,StartTime]' --output text | awk '{print $1"\t"$2}')
do
  # Get the snapshot start time in seconds since epoch
  snapshot_start_time=$(date -d "$(echo "$snapshot_id" | awk '{print $2}')" +%s)
  
  # Calculate the age of the snapshot in days
  age=$(( (current_date - snapshot_start_time) / 86400 ))

  # Check if the age exceeds the threshold
  if [ "$age" -gt "$threshold" ]; then
    # Export the snapshot to a file in the export directory
    export_file="$export_dir/snapshot_$snapshot_id.txt"
    aws ec2 describe-snapshots --snapshot-ids "$snapshot_id" --output text > "$export_file"
    echo "Exported snapshot $snapshot_id to $export_file"
  fi
done

