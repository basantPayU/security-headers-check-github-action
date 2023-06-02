#! /bin/bash

if [[ $# == 0 ]]; then
    echo "Usage: url"
    echo "Please provide the URL"
    exit 1
fi

RESPONSE_HEADER_FILE=./headers.txt

URL=${1}

# call the curl and store the response headers in a file called headers.txt.
RESPONSE_HEADERS=$(curl -D "${RESPONSE_HEADER_FILE}" "${URL}" -I )

# array of required headers and the values/directives they should hold.
declare -A REQUIRED_HEADERS=(
	['Strict-Transport-security']="max-age=63072000; includeSubDomains; preload"
	['X-frame-options']="SAMEORIGIN"
	['X-Content-Type-Options']="nosniff"
	['Referrer-Policy']="strict-origin-when-cross-origin"
	['Permissions-Policy']="geolocation=(),midi=(),sync-xhr=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self),payment=()"
	['Content-Security-Policy']="connect-src default-src img-src manifest-src media-src object-src script-src style-src" 
)

#array of missing headers to be filled if any.
MISSING_HEADERS=()
# missing CSP directives.
MISSING_CSP_DIRECTIVES=()
# Grade/Present Headers count.
GRADE=0

RED="\033[1;31m"
GREEN="\033[1;32m"

printMissingHeaders() {
  # TODO: this missing headers should be output
  echo -e " ${RED} The following headers are missing:"
  # Print missing Headers
    for str in "${MISSING_HEADERS[@]}"; do
      echo -e " ${RED} ${str}"
    done

   #Print missing CSP directives if any by iterating over the MISSING_CSP_DIRECTIVES array
   for str in "${MISSING_CSP_DIRECTIVES[@]}"; do
      echo -e " ${RED} ${str}"
    done
}

checkContentSecurityPolicy() {
  # check if all the directives required for CSP are present
  CSP_DIRECTIVES_PRESENT_COUNT=0
  for i in ${REQUIRED_HEADERS[Content-Security-Policy]}; do
    
    grep -i -q "${i}" "${RESPONSE_HEADER_FILE}"

    if [ "$?" == 0 ]; then
      # for every header that is present, increase the CSP_DIRECTIVES_PRESENT_COUNT count.
      CSP_DIRECTIVES_PRESENT_COUNT=$((CSP_DIRECTIVES_PRESENT_COUNT+1))
    else
      # for every missing CSP dorective, add the name of the missing directive to the MISSING_CSP_DIRECTIVES array.
      MISSING_CSP_DIRECTIVES+=("CSP: missing directive ${i}")
    fi
  done

  if [ $CSP_DIRECTIVES_PRESENT_COUNT -lt ${#REQUIRED_HEADERS[Content-Security-Policy[@]]} ]; then
    return 1
  else 
    return 0
  fi
}

# iterate over the file and check if all the required headers are present
for key in "${!REQUIRED_HEADERS[@]}"; do
  if [ "${key}" == "Content-Security-Policy" ]; then
    checkContentSecurityPolicy
  else 
    # check if each key(response header) has correct value 
    grep -i -q "${key}: ${REQUIRED_HEADERS[$key]}" "${RESPONSE_HEADER_FILE}" 
    
  fi   

  exitCode="$?"
  if [ "${exitCode}" -eq 0 ]; then
  # for every header that is present, increase the grade count.
  GRADE=$((GRADE+1))
  else
  # for every missing header, add the name of the header to the MISSING_HEADERS array.
  MISSING_HEADERS+=("${key}")
  fi

done

echo "the grade is: ${GRADE}"

removeTempFile() {
  rm "${RESPONSE_HEADER_FILE}"
}

# if the grade count is less than the length of the REQUIRED_HEADERS array
if [ $GRADE -lt ${#REQUIRED_HEADERS[@]} ]; then
    echo "rating=failure" >> $GITHUB_OUTPUT
    printMissingHeaders
    removeTempFile
    # exit 0
    exit 1
else 
   echo "${GREEN} All Security Headers are present"
   removeTempFile
    echo "rating=success" >> $GITHUB_OUTPUT
   exit 0
fi