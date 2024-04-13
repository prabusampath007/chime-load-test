# chime-load-test

Build:
1. npm run build to build the lambda function
2. Install terraform
3. Terraform apply (pass necessary values via tfvars file)
4. Purchase phone number from Chime SDK console
5. Assign the purchased phone number to deployed voice connector
6. Finally install Jmeter for doing load test

Execution:
1. Open Jmeter script
2. Update the API url
3. Update the request body fromPhoneNumber and toPhoneNumber (Voice connector number)
4. In the SIPp server go to `/home/ubuntu/sipp-3.6.1` and update the SIPp public IP in the uas.sh file
5. Run the uas.sh file in SIPp server to accept calls
6. Finally run the Jmeter 