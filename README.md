# Apigee Monetization Demo Kickstarter

This repository contains a script and API proxy to quickly apply the necessary Edge configurations for Monetization.  
The script covers the first 5 steps described [here](https://docs.apigee.com/api-platform/monetization/set-monetization#teamsetup)

*Note:* 
- Use this script to configure Monetization with basic and initial settings only. For specific customizations, please make use of the Monetization API and Edge UI.
- The script comes with predefined variables which are shown in brackets during execution

## Prerequisites

- Apigee account
- Monetization enabled in your Apigee organization
- Initial monetization setup completed - as described [here](https://docs.apigee.com/api-platform/monetization/set-monetization#teamsetup)
- [apigeetool](https://www.npmjs.com/package/apigeetool) installed
- Understanding of the [Apigee Monetization API](https://apidocs.apigee.com/api-reference/content/monetization-apis) 

## Steps

- Export your Apigee username, password and target organization as environment variables
(you can also skip this and enter these details within the script)

`export USERNAME=<your_apigee_username>`
`export PASSWORD=<your_apigee_password>`
`export ORG_NAME=<your_org_name>`

- Run the script

`./setup_edge.sh`

#### 1. Org Profile
- After the credentials and org name have been set, the first step allows you to configure the profile settings. Review the JSON payload returned showing the current configuration. For Monetization, an organization address and default currency is required.
- Enter the default currency
- Select whether you want to edit the current profile
- If `y`, enter the details
- Review the response, which now includes an address JSON object at the very top
- Continue with [Enter]
#### 2. T&Cs
- Select whether you want to add T&Cs. Look out for the `totalRecords` attribute in the payload above.
- if `y`, enter the T&Cs URL and text description
#### 3. Currencies
- The next response shows the available currencies. Again, look out for the `totalRecords` attribute
- In case (a) there's no currency available or (b) the previously selected default currency is not included, hit `n`
#### 4. Deploying API Proxy and Product
- If you wish to continue deploying a basic API Proxy with the necessary policies and a corresponding API Product, hit `Enter`
- Select the target environment
- Verify that the API Product deployment resulted in a `201 Created` response

That's it. For Product Bundles and Rate Plans, switch to the [Edge UI](http://apigee.com).



## Disclaimer

This is not an officially supported Google product.