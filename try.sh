#! /usr/local/bin/bash

source utils.sh
source constants.sh

# if [[ $# == 0 ]]; then
#     echo "Usage: url"
#     echo "Please provide the URL"
#     exit 1
# fi

RESPONSE_HEADER_FILE=./headers.txt

# URL='https://www.payufin.in/'
URL='https://sandbox-web.lazypay.in/'
# URL=${1}

main() {
  # #call the curl and store the response headers in a file called headers.txt.
  # RESPONSE_HEADERS=$(curl -D "${RESPONSE_HEADER_FILE}" "${URL}" -I) 

  # iterate over the file and check if all the required headers are present
  for key in "${!REQUIRED_HEADERS[@]}"; do

    case $key in
    Content-Security-Policy)
      checkContentSecurityPolicy
      ;;
    Referrer-Policy)
      checkReferrerPolicy
      ;;
    Permissions-Policy)
      checkPermissionPolicy
      ;;
    Strict-Transport-security)
      checkStrictTransportSecurity
      ;;
    X-frame-options)
      checkXFrameOptions
      ;;
    X-Content-Type-Options)
      checkXContentTypeOptions
      ;;
    esac

    exitCode="$?"
    # echo " bazinga return value from function" $exitCode
    if [ "${exitCode}" -eq 0 ]; then
      # for every header that is present, increase the grade count.
      GRADE=$((GRADE + 1))
    else
      # for every missing header, add the name of the header to the MISSING_HEADERS array.
      MISSING_HEADERS+=("${key}")
    fi

  done

  # echo "the grade is: ${GRADE}"

  # if the grade count is less than the length of the REQUIRED_HEADERS array
  if [ $GRADE -lt ${#REQUIRED_HEADERS[@]} ]; then
    printMissingHeaders
    # removeTempFile
    # echo "rating=failure" >> $GITHUB_OUTPUT
    exit 0
  else
   echo -e " ${GREEN}All Security Headers are present"
    #  removeTempFile
    # echo "rating=success" >> $GITHUB_OUTPUT
    exit 0
  fi
}

main

# TODO test for all edge cases (ONGOING)
