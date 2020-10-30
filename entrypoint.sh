#!/bin/sh

from="$($INPUT_FROM_DATE --iso-8601=date)"
to="$($INPUT_TO_DATE --iso-8601=date)"

employees="$INPUT_EMPLOYEE_LIST"
employees=$(echo $employees | tr ";" "\n")
echo "$employees" > all
whos_out() {
for employee in $employees; do
  xmllint --noout --xpath '//calendar/item[@type="timeOff"]/employee[@id="'$employee'"]' tmp > /dev/null 2>&1
  person_out=$(echo $?)
  if [ $person_out -eq 0 ]; then
    xml_out=$(echo $xml_out\;$employee)
  fi
done
out=$(echo "${xml_out:1}" | tr ";" "\n")
echo "$out" > out
if "$INPUT_PEOPLE_IN_TODAY"; then
  attendance_in=$(diff --changed-group-format="%<" --unchanged-line-format="" all out)
fi
if "$INPUT_PEOPLE_OUT_TODAY"; then
  attendance_out=$(diff --old-group-format="%>" all out)
fi
attendance="${attendance_in}${attendance_out}"
}
get_employees() {
  out=$(curl -s -u "$INPUT_BAMBOOHR_API_TOKEN:x" "https://api.bamboohr.com/api/gateway.php/$INPUT_SUBDOMAIN/v1/time_off/whos_out/?start=$from&end=$to")
  echo "$out" > tmp
  if [ "xmllint --noout tmp" ]; then
    echo "[+] Obtained employee list."
  else
    echo '[!] Something went wrong querying BambooHR.'
    exit 1
  fi
}
get_fields() {
  employees="$attendance"
  for employee in $employees; do
    fields=$(curl -s -u "$INPUT_BAMBOOHR_API_TOKEN:x" "https://api.bamboohr.com/api/gateway.php/$INPUT_SUBDOMAIN/v1/employees/$employee/?fields=$INPUT_BAMBOOHR_FIELDS" | cut -d '>' -f 2 | cut -d '<' -f 1)
    echo "$fields" >> employee_info.txt
  done
  echo '[+] Wrote employee fields to employee_info.txt.'
}
get_employees
whos_out
get_fields
