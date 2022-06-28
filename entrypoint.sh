#!/bin/bash

from="$($INPUT_FROM_DATE --iso-8601=date)"
to="$($INPUT_TO_DATE --iso-8601=date)"

input_employees="$INPUT_EMPLOYEE_LIST"
input_employees=$(echo $input_employees | tr "," "\n")

get_absent_employees() {
  out=$(curl -s -H 'Accept: application/json' -u "$INPUT_BAMBOOHR_API_TOKEN:x" "https://api.bamboohr.com/api/gateway.php/$INPUT_BAMBOOHR_SUBDOMAIN/v1/time_off/whos_out/?start=$from&end=$to")
  if jq -e . >/dev/null 2>&1 <<<"$out"; then
    echo "[+] Obtained employee list."
  else
    echo '[!] Something went wrong querying BambooHR.'
    exit 1
  fi
}

get_fields() {
  for employee in $input_employees; do
    out_ids=$(echo $out | jq '.[].employeeId')
    if echo "$out_ids" | grep -q $employee; then
      curl -s -H 'Accept: application/json' -u "$INPUT_BAMBOOHR_API_TOKEN:x" "https://api.bamboohr.com/api/gateway.php/$INPUT_BAMBOOHR_SUBDOMAIN/v1/employees/$employee/?fields=$INPUT_BAMBOOHR_FIELDS" >> employee_info.txt
    else
      echo "[+] No employees from the list out today."
      exit 0
    fi
  done
  echo '[+] Wrote absent employee fields to employee_info.txt.'
}

get_absent_employees
get_fields
