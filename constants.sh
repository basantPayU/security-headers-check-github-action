#!/bin/bash

# array of required headers and the values/directives they should hold.
declare -A REQUIRED_HEADERS=(
  ['Referrer-Policy']="strict-origin-when-cross-origin origin-when-cross-origin"
  ['X-frame-options']="SAMEORIGIN"
  ['X-Content-Type-Options']="nosniff"
  ['Strict-Transport-security']="max-age=; includeSubDomains; preload"
  ['Permissions-Policy']="geolocation=(),midi=(),sync-xhr=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self),payment=()"
  ['Content-Security-Policy']="default-src connect-src img-src manifest-src media-src object-src script-src style-src"
)

#array of missing headers to be filled if any.
MISSING_HEADERS=()
MISSING_CSP_DIRECTIVES=()
MISSING_STRICT_TRANSPORT_SECURITY=()
UNALLOWED_PERMISSIONS=()
UNALLOWED_REFFER_POLICY=()
UNALLOWED_X_FRAME_OPTIONS=()
UNALLOWED_X_CONTENT_TYPE_OPTIONS=()



# Grade/Present Headers count.
GRADE=0

RED="\033[1;31m"
GREEN="\033[1;32m"