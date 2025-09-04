#!/bin/bash
# Sync Nginx logs to S3
aws s3 sync ~/logs s3://sparkrock-logs-<account-id>-<region>/nginx/ --delete

