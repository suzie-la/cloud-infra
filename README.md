# CD12352 - Infrastructure as Code Project Solution
# MENGUOPE FONTANG Suzie Laure

## Structure
The project is made up of two main stacks:
- The network stack for network components
- The webservers stack for EC2 resources and associated components

The bucket creation stack allow us to easily launch a s3 bucket that will store our static files.

The overall project directory structure is as follows:
udagram-project
├── bucket
│   ├── bucket.yml
│   └── bucket-parameters.json
├── network
│   ├── network.yml
│   └── network-parameters.json
├── webservers
│   ├── udagram.yml
│   └── udagram-parameters.json
├── src
│   └── index.html
├── scripts
│   └── run-stack.sh
├── README.md
└── udagram-architecture.png

## Spin up instructions
To spin up the architecture, get into the project folder
```
cd udagram-project
```
1- Create the bucket and upload the application static files into it
Create the s3 bucket using the command:
```
bash scripts/run-stack.sh deploy us-east-2 udagram-s3 ./bucket/bucket.yml ./bucket/bucket-parameters.json
``` 
Use the following AWS CLI command to upload the source folder into the s3 bucket
```
aws s3 cp ./src s3://udagram-s3/ --recursive
```
2- Create the Network stack
Run the command:
```
bash scripts/run-stack.sh deploy us-east-2 udagram-network ./network/network.yml ./network/network-parameters.json
```

3- Create a keypair that will be use for our bastion host and instances creation
Use the command:
```
aws ec2 create-key-pair --key-name "udagram-key" --query 'KeyMaterial' --output text > "udagram-key.pem"
```
Secure the downloaded key pair file by giving permissions 400
```
chmod 400 udagram-key.pem
```
4- Create the webservers stack
Run the command:
```
bash scripts/run-stack.sh deploy us-east-2 udagram-web ./webservers/udagram.yml ./webservers/udagram-parameters.json
```
Once the infrastructure is up you can go to the app using the Loadbalancer DNS. Since it is an output value of the udagram-web stack, we can display it in the terminal with:
```
aws cloudformation describe-stacks --stack-name udagram-web --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" --output table
```
You will get the index.html page displaying the message: `It works! Udagram, Udacity`
Working Test Link: http://udagra-WebAp-hcOuc33UwxyC-136126565.us-east-2.elb.amazonaws.com

## Tear down instructions
To tear down the infrastructure, use the following steps
1- Destroy the various stacks progressively
```
bash scripts/run-stack.sh delete us-east-2 udagram-web
bash scripts/run-stack.sh delete us-east-2 udagram-network
```
2- Empty the s3 bucket and destroy it
```
aws s3 rm s3://udagram-s3 --recursive
```
```
bash scripts/run-stack.sh delete us-east-2 udagram-s3
```
3- Delete the key pair
```
aws ec2 delete-key-pair --key-name "udagram-key"
```
## Other considerations
### Troubleshooting web server
After the stack created, you can login to the bastion host in order to access the web servers. 
Note: This was done on a Windows computer.

```
# start the ssh-agent if not running
eval "$(ssh-agent -s)"
ssh-add ./udagram-key.pem
ssh -A -i ./udagram-key.pem ubuntu@[bastionHostIP]
```
Once in the bastion host, simply use the ssh command to login to a web server instance.
```
ssh ubuntu@[webserverIP]
```