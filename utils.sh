#!/bin/bash

source constants.sh

# todo: this filaname should be dynamic
# Read the contents of the headers.txt file

# headers=$(cat "${RESPONSE_HEADER_FILE}")
headers=$(cat headers.txt)

removeTempFile() {
  rm "${RESPONSE_HEADER_FILE}"

}

printMissingHeaders() {
  # TODO: this missing headers should be output
  echo -e " ${RED} The following headers problems were encountered:"

  #Print missing CSP directives if any by iterating over the MISSING_CSP_DIRECTIVES array
  for str in "${MISSING_CSP_DIRECTIVES[@]}"; do
    echo -e " ${RED} ${str}"
  done

  #Print missing Strict-Transport-security directives if any by iterating over the MISSING_STRICT_TRANSPORT_SECURITY array
  for str in "${MISSING_STRICT_TRANSPORT_SECURITY[@]}"; do
    echo -e " ${RED} Missing strict-transport-security ${str}"
  done

  for str in "${UNALLOWED_PERMISSIONS[@]}"; do
    echo -e " ${RED} Unallowed Permission ${str}"
  done

  for str in "${UNALLOWED_REFFER_POLICY[@]}"; do
    echo -e " ${RED} Unallowed Reffer policy: ${str}"
  done

  for str in "${UNALLOWED_X_FRAME_OPTIONS[@]}"; do
    echo -e " ${RED} Unallowed X_FRAME policy: ${str}"
  done

  for str in "${UNALLOWED_X_CONTENT_TYPE_OPTIONS[@]}"; do
    echo -e " ${RED} Unallowed X_CONTENT_TYPE_ policy: ${str}"
  done
}

checkStrictTransportSecurity() {
  # Get the value of 'Strict-Transport-Security' from headers
  stHeader=$(grep -i "strict-transport-security" <<<"$headers")

  # Extract the value of 'Strict-Transport-Security' using text manipulation
  stValue=$(echo "$stHeader" | awk -F: '{ print $2 }' | tr -d '[:space:]')

  # The required policies
  requiredPolicies=("max-age" "includeSubDomains" "preload")

  # Initialize the array to store missing policies
  MISSING_STRICT_TRANSPORT_SECURITY=()

  # Check if any required policy is missing in stValue
  for policy in "${requiredPolicies[@]}"; do
    if [[ ! "$stValue" == *"$policy"* ]]; then
      MISSING_STRICT_TRANSPORT_SECURITY+=("$policy")
    fi
  done

  # If there are missing policies, output them and exit with status 1
  if [[ ${#MISSING_STRICT_TRANSPORT_SECURITY[@]} -gt 0 ]]; then
    return 1
  fi

  return 0
}

# Content-Security-Policy: all directives should be present and the default policy should have a directive of self
checkContentSecurityPolicy() {

  # Iterate over each header value in 'REQUIRED_HEADERS['Content-Security-Policy']'
  for header in ${REQUIRED_HEADERS['Content-Security-Policy']}; do
    # Construct the search pattern with 'self' for 'default-src' header
    search_pattern="$header"
    if [ "$header" = "default-src" ]; then
      search_pattern+=" 'self'"
    fi

    # Use 'grep' to search for the header value in the 'headers' variable
    if ! grep -q "$search_pattern" <<<"$headers"; then
      # If the header is not found
      MISSING_CSP_DIRECTIVES+=("Missing CSP directive: $search_pattern")
    fi
  done

  # Check if 'MISSING_CSP_DIRECTIVES' array has at least one entry
  if [ ${#MISSING_CSP_DIRECTIVES[@]} -gt 0 ]; then
    return 1
  else
    return 0
  fi

}

# REQUIRED_HEADERS['Permissions-Policy'] describes permissions policies, that can be allowed
checkPermissionPolicy() {

  # Search for the line containing 'permissions-policy'
  line=$(echo "$headers" | grep -i "permissions-policy")

  # Extract the value of 'permissions-policy' using text manipulation
  permissionPresentInHeader=$(echo "$line" | awk -F: '{ print $2 }' | tr -d '[:space:]')

  # Split the words/permissions of permissionPresentInHeader into an array
  IFS=',' read -ra words <<<"$permissionPresentInHeader"

  allowedPermission=${REQUIRED_HEADERS['Permissions-Policy']}

  # Check each word if it exists in allowedPermission
  for word in "${words[@]}"; do
    if [[ ! "$allowedPermission" == *"$word"* ]]; then
      UNALLOWED_PERMISSIONS+=("Permission-policy not allowed: $word")
    fi
  done

  # Check if UNALLOWED_PERMISSIONS has entries and return appropriate exit status
  if [[ ${#UNALLOWED_PERMISSIONS[@]} -gt 0 ]]; then
    return 1
  else
    return 0
  fi

}

checkReferrerPolicy() {
  # Search for the line containing 'referrer-policy'
  line=$(grep -i "referrer-policy" <<<"$headers")

  # Extract the value of 'referrer-policy' using text manipulation
  referrerPolicy=$(awk -F: '{ print $2 }' <<<"$line" | tr -d '[:space:]')

  # Check if the referrerPolicy is valid
  if [[ "$referrerPolicy" != "strict-origin-when-cross-origin" && "$referrerPolicy" != "origin-when-cross-origin" ]]; then
    UNALLOWED_REFFER_POLICY+=("$referrerPolicy")
  fi

  # If there are unallowed referrer policies, return exit status 1
  if [[ ${#UNALLOWED_REFFER_POLICY[@]} -gt 0 ]]; then
    return 1
  fi

  return 0
}

checkXFrameOptions() {
  # Search for the line containing 'x-frame-options'
  line=$(grep -i "x-frame-options" <<<"$headers")

  # Extract the value of 'x-frame-options' using text manipulation
  xFrameOptions=$(awk -F: '{ print $2 }' <<<"$line" | tr -d '[:space:]')

  # Check if the xFrameOptions is 'SAMEORIGIN'
  if [[ "$xFrameOptions" != "SAMEORIGIN" ]]; then
    # If it's not 'SAMEORIGIN', add the value to the error array
    UNALLOWED_X_FRAME_OPTIONS=("$xFrameOptions")
    return 1
  fi

  return 0
}

checkXContentTypeOptions() {
  # Search for the line containing 'x-content-type-options'
  line=$(grep -i "x-content-type-options" <<<"$headers")

  # Extract the value of 'x-content-type-options' using text manipulation
  xContentTypeOptions=$(awk -F: '{ print $2 }' <<<"$line" | tr -d '[:space:]')

  # Check if the xContentTypeOptions is 'nosniff'
  if [[ "$xContentTypeOptions" != "nosniff" ]]; then
    # If it's not 'nosniff', add the value to the error array
    UNALLOWED_X_CONTENT_TYPE_OPTIONS=("$xContentTypeOptions")
    return 1
  fi

  return 0
}
