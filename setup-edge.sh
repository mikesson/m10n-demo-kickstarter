#!/bin/bash

# Copyright 2019 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#  https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo -e "\n>>> This script will guide you through the first steps of configuring M10n on Apigee Edge";
echo -e "==========================\n";
echo -e "If you haven't populated the environment variables USERNAME, PASSWORD and ORG_NAME yet, you are prompted to enter them now.\n";
read -p "[Press any key to continue] " continue_script

if [ -z "${USERNAME}" ] && [ -z "${PASSWORD}" ] && [ -z "${ORG_NAME}" ] 
then
    echo -e "\nEnvironment variables not found, please enter the necessary details below ...\n";
    echo -e "Enter username:"
    read username
    echo -e "Enter password:"
    read -s password
    echo -e "********"
    echo -e "Enter organization name:"
    read org_name
else
    echo -e "\nEnvironment variables found, applying them to this script ...\n\n";
    username=${USERNAME}
    password=${PASSWORD}
    org_name=${ORG_NAME}
fi

read -p "Let's get started ... [Press any key to continue] " continue_script

#auth header for Management API calls
auth_header_encoded_full="Authorization: Basic $(echo -n $username:$password | base64)"
echo -e "\n>>> Current org profile settings:\n==========================\n\n";
# getting current org configuration
curl -v -H "Accept: application/json" -H "$auth_header_encoded_full"  \
"https://api.enterprise.apigee.com/v1/mint/organizations/$org_name"
echo -e "\n\n\n>>> 1. Organization Profile\n==========================\n\n";
read -p "Enter the default currency for your setup (ISO Code) [GBP]: " default_currency
    default_currency=${default_currency:-GBP}
    #echo default_currency
echo -e "\n\n"
read -p "Do you want to edit your org profile with test data to make it ready for M10n? (suggested if running it the first time) [Y/n] " edit_org_profile
edit_org_profile=${edit_org_profile:-y}
if [ "$edit_org_profile" = "y" ]  || [ "$edit_org_profile" = "Y" ]
then
    echo -e "\n\n\n>>> Applying the updated org profile based on your input below ....\n==========================\n\n";
    read -p "Enter the organisation address - street [Test Street]: " address_street
    address_street=${address_street:-Test Street}
    #echo $address_street
    read -p "Enter the organisation address - city [Test City]: " address_city
    address_city=${address_city:-Test City}
    #echo $address_city
    read -p "Enter the organisation address - country code [UK]: " address_country_code
    address_country_code=${address_country_code:-UK}
    #echo address_country_code
    read -p "Enter the organisation address - state [London]: " address_state
    address_state=${address_state:-London}
    #echo address_state
    read -p "Enter the organisation address - ZIP code [SW1W 123]: " address_zip
    address_zip=${address_zip:-SW1W 123}
    # applying changes to the config
    curl -v -X PUT "https://api.enterprise.apigee.com/v1/mint/organizations/$org_name" \
    -H "Content-Type: application/json" -H "$auth_header_encoded_full" -d "{
        \"address\" : [ { 
            \"address1\" : \"$address_street\", 
            \"city\" : \"$address_city\", 
            \"country\" : \"$address_country_code\", 
            \"id\" : \"corp-test-address\", 
            \"isPrimary\" : true, 
            \"state\" : \"$address_state\", 
            \"zip\" : \"$address_zip\"
        } ],
    \"approveTrusted\" : false, 
    \"approveUntrusted\" : false, 
    \"billingCycle\" : \"CALENDAR_MONTH\", 
    \"country\" : \"$address_country_code\", 
    \"currency\" : \"$default_currency\", 
    \"description\" : \"$org_name\", 
    \"hasBillingAdjustment\" : true, 
    \"hasBroker\" : false, 
    \"hasSelfBilling\" : false, 
    \"hasSeparateInvoiceForProduct\" : false,
    \"id\" : \"$org_name\", 
    \"issueNettingStmt\" : false, 
    \"logoUrl\" : \"https://pngimage.net/wp-content/uploads/2018/06/sample-logo-png-6.png\", 
    \"name\" : \"$org_name\", 
    \"nettingStmtPerCurrency\" : false, 
    \"regNo\" : \"RegNo-1234-$org_name\", 
    \"selfBillingAsExchOrg\" : false, 
    \"selfBillingForAllDev\" : false, 
    \"separateInvoiceForFees\" : false, 
    \"status\" : \"ACTIVE\", 
    \"supportedBillingType\" : \"BOTH\", 
    \"taxModel\" : \"HYBRID\", 
    \"taxRegNo\" : \"TaxRegNo-1234-$org_name\", 
    \"timezone\" : \"UTC\" }"
    echo -e "\n\n\n"
    read -p "Review the response above and hit [ENTER] if you received a 200 OK / 201 Created ..." continue_script
else
    echo -e "\nOk, skipping org profile modification ... \n\n"
fi
  # 2. Specify T&Cs
echo -e "\n\n\n2. Specifying T&Cs\n==========================\n\n"
echo -e "\nHere's the current list of T&Cs:\n"
curl -H "Accept: application/json" -H "$auth_header_encoded_full"  \
-v "https://api.enterprise.apigee.com/v1/mint/organizations/$org_name/tncs"
echo -e "\n\n"
read -p "Do you want to add T&Cs? Check the output above, you might already have them! [Y/n] " add_new_tcs
add_new_tcs=${add_new_tcs:-y}
if [ "$add_new_tcs" = "y" ]  || [ "$add_new_tcs" = "Y" ]
then
    echo -e "\n\n\n>>> Specifying T&Cs based on your input below ....\n==========================\n\n";
    read -p "Enter the T&Cs URL [https://docs.apigee.com/api-platform/monetization/specify-terms-and-conditions]: " termsconditions_url
    termsconditions_url=${termsconditions_url:-https://docs.apigee.com/api-platform/monetization/specify-terms-and-conditions}
    read -p "Enter the T&Cs text [Please refer to the T&Cs link]: " termsconditions_text
    termsconditions_text=${termsconditions_text:-Please refer to the T&Cs link}
    read -p "Enter the T&Cs start date (has to be later than today, in the YYYY-MM-DD format) [2019-03-01]: " termsconditions_startdate
    termsconditions_startdate=${termsconditions_startdate:-2019-03-01} 
    echo -e "\n\n"
    curl -X POST "https://api.enterprise.apigee.com/v1/mint/organizations/$org_name/tncs" \
    -H "Content-Type: application/json" -H "$auth_header_encoded_full" -d "{
            \"url\" : \"$termsconditions_url\", 
            \"tncText\" : \"$termsconditions_text\", 
            \"version\" : \"0.1\", 
            \"startDate\" : \"$termsconditions_startdate\" }"
    echo -e "\n\n\n"
    read -p "Review the response above and hit [ENTER] if you received a 200 OK / 201 Created ..." continue_script
    echo -e "\n\n\n"
else
    echo -e "\nOk, skipping adding new T&Cs ... \n\n"
fi
# 3. Let's check the supported currencies
echo -e "\n>>> 3. Checking the supported currencies: ....\n==========================\n\n";
  curl -X GET "https://api.enterprise.apigee.com/v1/mint/organizations/$org_name/supported-currencies" \
  -H "Accept: application/json" -H "$auth_header_encoded_full"
echo -e "\n\n\n"
echo -e "Is totalRecords = 0? If so, then your default currency from above has to be added ($default_currency).\n\n"
read -p "Is the default currency '$default_currency' available in the JSON? [Y/n] " is_currency_available
is_currency_available=${is_currency_available:-y}
if [ "$is_currency_available" = "y" ]  || [ "$is_currency_available" = "Y" ]
then
    echo -e "\nOk, skipping adding it as a new currency ... \n\n"
else
    echo -e "\nOk, let's add the default currency now ($default_currency), just a few more settings required ... \n\n"
    read -p "Enter the currency display name [Pound Sterling]: " currency_display_name
    currency_display_name=${currency_display_name:-Pound Sterling}
    read -p "Is the currency virtual? (enter 'true' or 'false' in lowercase letters) [false]: " currency_is_virtual
    currency_is_virtual=${currency_is_virtual:-false}
    read -p "What's the currency status? (enter ACTIVE or INACTIVE in uppercase letters) [ACTIVE]: " currency_status
    currency_status=${currency_status:-ACTIVE}
    echo -e "\n>>> Adding the currency now ....\n==========================\n\n";
    curl -v "https://api.enterprise.apigee.com/v1/mint/organizations/$org_name/supported-currencies" \
    -H "Content-Type: application/json" -H "$auth_header_encoded_full" -d "{
     \"description\": \"$currency_display_name\",
     \"displayName\": \"$currency_display_name\",
     \"virtualCurrency\": $currency_is_virtual,
     \"name\": \"$default_currency\",
     \"organization\": {
       \"id\": \"$org_name\"
     },
     \"status\": \"$currency_status\"
    }"
    echo -e "\n\n\n"
    read -p "Review the response above and hit [ENTER] if you received a 200 OK / 201 Created ..." continue_script
    echo -e "\n\n\n"
fi
echo -e "\n>>> Base Monetization Setup Complete\n==========================\n\n";
read -p "Do you want to continue deploying API Proxy and Product? [Y/n] " continue_script
continue_deploy_1=${continue_script:-y}
if [ "$continue_script" = "y" ]  || [ "$continue_script" = "Y" ]
then
    echo -e "\n>>> 4. API Proxy and Product Deployment\n==========================\n\n"
    proxy_name="m10n-sample-bankingproducts-v1"
    apiproduct_name="m10n-sample-bankingproducts-v1"
    apiproduct_display_name="Banking Products API v1 (M10n)"
    apiproduct_description="Banking Product Essentials"
    echo -e "Step 1 - Deploying the API proxy (name: $proxy_name) containing all necessary m10n policies ...\n==========================\n\n"
    read -p "What environment? [test] " env
    env=${env:-test}
    echo -e "\nDeploying to environment $env now ...\n"
    #cd proxies
    apigeetool deployproxy -u $username -p $password -o $org_name -e $env -n $proxy_name -d proxies
    #cd ..
    echo -e "\nStep 2 - Creating the API Product (name: '$apiproduct_name') ...\n"
    curl -v -i -H "Content-Type: application/json" -H "$auth_header_encoded_full" -d "{
    \"name\" : \"$apiproduct_name\",
    \"displayName\": \"$apiproduct_display_name\",
    \"approvalType\": \"auto\",
    \"attributes\": [
        {
        \"name\": \"access\",
        \"value\": \"public\"
        }
    ],
    \"description\": \"$apiproduct_description\",
    \"apiResources\": [
        \"/\",
        \"/**\"
    ],
    \"environments\": [ \"test\", \"prod\"],
    \"proxies\": [\"$proxy_name\"],
    \"scopes\": [\"\"]
    }" "https://api.enterprise.apigee.com/v1/organizations/$org_name/apiproducts"
    echo -e "\n\n(Verify that the status code is '201 Created'.)\n"
else
    echo -e "\nOk, skipping ... \n\n"
fi
echo -e "\n\n >>>> That's it, configure Product Bundles and Rate Plans via the Edge UI, now.\n"