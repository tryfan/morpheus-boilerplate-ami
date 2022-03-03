# Make Boilerplate Morpheus

## Requirements
- Packer
- Ansible
  - boto3 python module
- AWS credentials supplied to Packer and Ansible

## Build the AMI
Run `build_aws.sh <Morpheus version> <AWS Owner ID>` to build an AMI in your AWS account.

## Make a Morpheus from the AMI
Run `create_ec2s.sh <Morpheus version>` to create a Morpheus appliance using the Ansible playbook found in `make_ec2.yml`

The default username in Morpheus is admin.  The Ansible playbook will output the ec2 DNS name and the password, which is: `<AWS instance id>@AWS`

You can use these AMIs in other build processes.  My own use case was creating multiple versions of Morpheus for testing our open source contributions.

## NOTE
The `morpheus_fqdn` tag on the instance is used on first startup to set the URL for Morpheus.  If it is missing, It will be set to the public IPv4 address of the instance.