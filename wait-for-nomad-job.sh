#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <job-id>"
  exit 1
fi

JOB_ID="$1"
NOMAD_ADDR="${2:-http://nomad.service.consul:4646}"

until [ "$(curl -s --fail "${NOMAD_ADDR}/v1/job/${JOB_ID}/allocations" | jq -r '.[].ClientStatus' | grep -c "running")" -gt 0 ]; do
  echo "Waiting for job ${JOB_ID} to become healthy..."
  sleep 5
done

echo "Job ${JOB_ID} is healthy."
