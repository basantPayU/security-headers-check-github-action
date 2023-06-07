#!/bin/bash

# Array to store missing permissions
unallowedPermissions=()

# REQUIRED_HEADERS['Permissions-Policy'] describes permissions policies, that can be allowed
checkPermissionPolicy() {
  # Read the contents of the headers.txt file
  headers=$(cat headers.txt)

  # Search for the line containing 'permissions-policy'
  line=$(echo "$headers" | grep -i "permissions-policy")

  # Extract the value of 'permissions-policy' using text manipulation
  permissionPresentInHeader=$(echo "$line" | awk -F: '{ print $2 }' | tr -d '[:space:]')

  # Split the words of permissionPresentInHeader into an array
  IFS=',' read -ra words <<<"$permissionPresentInHeader"

  allowedPermission="geolocation=(),sync-xhr=(),connect=()"

  # Check each word if it exists in allowedPermission
  for word in "${words[@]}"; do
  echo "word re baba" $word "===" $allowedPermission
    if [[  "$allowedPermission" == *"$word"* ]]; then
      unallowedPermissions+=("$word")
    fi
  done

  # Output the unallowed permissions
  echo "unallowed Permissions:"
  for permission in "${unallowedPermissions[@]}"; do
    echo "$permission"
  done

}

checkPermissionPolicy
