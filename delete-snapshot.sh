#!/bin/bash

# Set the threshold in days (e.g., delete snapshots older than 30 days)
threshold=1

# Get the current date in seconds since epoch
current_date=$(date +%s)

# Iterate through each snapshot
for snapshot_id in $(aws ec2 describe-snapshots --query 'Snapshots[*].[SnapshotId,StartTime]' --output text | awk '{print $1"\t"$2}')
do
  # Get the snapshot start time in seconds since epoch
  snapshot_start_time=$(date -d "$(echo "$snapshot_id" | awk '{print $2}')" +%s)
  
  # Calculate the age of the snapshot in days
  age=$(( (current_date - snapshot_start_time) / 86400 ))

  # Check if the age exceeds the threshold
  if [ "$age" -gt "$threshold" ]; then
    # Delete the snapshot (replace <region> with the appropriate AWS region)
    aws ec2 delete-snapshot --region <region> --snapshot-id "$snapshot_id"
    echo "Deleted snapshot $snapshot_id"
  fi
done

