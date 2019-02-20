## AWS Tooling from Red Hat Partner Connect
Here we've provided a few handy scripts to use when managing infrastructure in AWS.
Most scripts are written in Python 3 and require the AWS Python SDK.
Also provided are bash shell scripts that wrap the AWS CLI for Linux are also provided.

To use these scripts, install the required packages listed below.

### RHEL 7 / CentOS 7

    yum install python3 python3-boto3 awscli

### Fedora

    dnf install python3 python3-boto3 awscli

Below is the list of provided scripts and a brief description of each:

 Name                     | Description
--------------------------|------------
aws_ec2_list_instances.py | Get a list of provisioned EC2 instances in the currently configured region (supports filtering by name)
aws_ec2_start_stop.py     | Start, stop or toggle all instances with names that begin with a specified string
