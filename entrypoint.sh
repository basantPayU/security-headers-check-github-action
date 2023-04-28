#! /bin/bash

if [[ $# == 0 ]]; then
    echo "Usage: url"
    echo "Please provide the URL"
    exit 1
fi

URL=${1}

# call the curl and store the response headers in a file called headers.txt.
RESPONSE_HEADERS=$(curl -D headers.txt "${URL}" -I )
# array of the required headers
REQUIRED_HEADERS=( "Strict-Transport-security" "Content-Security-Policy" "X-frame-options" "X-Content-Type-Options" "Referrer-Policy" "Permissions-Policy" )
#array of missing headers to be filled if any
MISSING_HEADERS=()
#
GRADE=0

printMissingHeaders() {
    echo "The following headers are missing:"
    for str in ${MISSING_HEADERS[@]}; do
        echo "${str}"
    done
}



# iterate over the file and check if all the required headers are present
for str in ${REQUIRED_HEADERS[@]}; do

  grep -i "${str}" ./headers.txt
  exitCode="$?"
  echo "exitcode for $str is $exitCode"
  if [ "${exitCode}" -eq 0 ]; then
   # for every header that is present, increase the grade count.
    GRADE=$((GRADE+1))
  else
    # for every missing header, add the name of the header to the MISSING_HEADERS array.
    MISSING_HEADERS+=("${str}")
  fi  
  
done

echo "the grade is: ${GRADE}"

# if the grade count is less than the length of the REQUIRED_HEADERS array
if [ $GRADE -lt ${#REQUIRED_HEADERS[@]} ]; then
    printMissingHeaders
    rm ./headers.txt
    exit 1
else 
   echo "All Security Headers are present"
   rm ./headers.txt
   exit 0
fi
