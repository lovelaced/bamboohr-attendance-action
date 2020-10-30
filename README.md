# BambooHR Attendance github action

This is a simple github action to retrieve a list of information about who is either in office, out of office, or both.

## Usage

Using the BambooHR API requires generating of an api token, which can be done by following the instructions [here](https://documentation.bamboohr.com/docs/getting-started).

```workflow
name: Every weekday morning, gather a list of people who are OOO today
on:
  schedule:
    - cron: '0 0 9 ? * MON-FRI *'
jobs:
  github_whos_out:
   runs-on: ubuntu-latest
   steps:
     - name: 
       uses: lovelaced/bamboohr-attendance-action@v0.0.1
       with:
         subdomain: "paritytech"
         api_token: ${{ secrets.BAMBOOHR_API_TOKEN }}
         people_in_today: false
         people_out_today: true
         bamboo_fields: "firstName,lastName"
```
