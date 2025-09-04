#!/bin/bash
# Sync Nginx logs to S3
aws s3 sync /home/ec2-user/logs s3://sparkrock-logs-476186718905-eu-north-1/nginx/ --delete
