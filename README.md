# Session-Manager-Data

#Verify AWS CLI Installation
aws --version

#Verify AWS Session Manager plugin
session-manager-plugin --version

#Verify AWS CLI user
aws sts get-caller-identity

#Start a session
aws ssm start-session --target <INSTANCE_ID>

#Input password as a secure string. Enter the below command which will prompt you for a password, then type a strong password and enter:
$Password = Read-Host -AsSecureString

#Create a local Widnows user
New-LocalUser "<USERNAME>" -Password $Password

#Add user to Remote Desktop Users group:
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "<USERNAME>"

#Start a RDP port forwarding session 
aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters portNumber="3389",localPortNumber="<LOCAL_PORT>"


