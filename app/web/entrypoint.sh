#!/bin/sh

if [ -n "$BASIC_AUTH_USER" ] && [ -n "$BASIC_AUTH_PASS" ]; then
  echo "Creating htpasswd file..."
  htpasswd -bc /etc/nginx/.htpasswd "$BASIC_AUTH_USER" "$BASIC_AUTH_PASS"
else
  echo "No BASIC_AUTH_USER/PASS provided, skipping auth setup"
fi

exec "$@"

