#!/usr/bin/python3

import sys
import boto3
import errno
from botocore.exceptions import ClientError

version = '0.0.1'

# Get the number of cli arguments
num_args = len(sys.argv)

short_help = 'For help, please run:\n\n\t{0} help'.format(sys.argv[0])

# Inform of an incorrect number of arguments and then exit with the corresponding exit code
def err_num_args():
    print('Error: Incorrect number of arguments: {0}'.format(num_args))
    print()
    print(short_help)
    sys.exit(errno.E2BIG)

if num_args < 2:
    err_num_args()
elif num_args > 3:
    err_num_args()
else:
    cmd_name = sys.argv[1].upper()

if cmd_name == 'START':
    if num_args < 3:
        err_num_args()

    username = sys.argv[2]

    usr_filter = '{0}*'.format(username)

    ec2_client = boto3.client('ec2')
    ec2_resource = boto3.resource('ec2')

    instances = ec2_resource.instances.filter(Filters=[{'Name': 'tag:Name', 'Values':[usr_filter]}])

    for instance in instances:
        try:
            ec2_client.start_instances(InstanceIds=[instance.id], DryRun=False)
            print('AWS EC2 instance', instance.id, 'has been started.')
        except ClientError as e:
            print(e)

elif cmd_name == 'STOP':
    if num_args < 3:
        err_num_args()

    username = sys.argv[2]

    usr_filter = '{0}*'.format(username)

    ec2_client = boto3.client('ec2')
    ec2_resource = boto3.resource('ec2')

    instances = ec2_resource.instances.filter(Filters=[{'Name': 'tag:Name', 'Values':[usr_filter]}])

    for instance in instances:
        try:
            ec2_client.stop_instances(InstanceIds=[instance.id], DryRun=False)
            print('AWS EC2 instance', instance.id, 'has been stopped.')
        except ClientError as e:
            print(e)

elif cmd_name == 'TOGGLE':
    if num_args < 3:
        err_num_args()

    username = sys.argv[2]

    usr_filter = '{0}*'.format(username)

    ec2_client = boto3.client('ec2')
    ec2_resource = boto3.resource('ec2')

    instances = ec2_resource.instances.filter(Filters=[{'Name': 'tag:Name', 'Values':[usr_filter]}])

    # Step through each of the instances returned from above
    for instance in instances:
        if 'stopped' in str(instance.state):
            try:
                ec2_client.start_instances(InstanceIds=[instance.id], DryRun=False)
                print('AWS EC2 instance', instance.id, 'has been started.')
            except ClientError as e:
                print(e)
        elif 'running' in str(instance.state):
            try:
                ec2_client.stop_instances(InstanceIds=[instance.id], DryRun=False)
                print('AWS EC2 instance', instance.id, 'has been stopped.')
            except ClientError as e:
                print(e)
        else:
            print('The instances aren\'t in the stopped or running state. Exiting...')

elif cmd_name == 'HELP':
    help_str = '''
  RHC AWS EC2 Start/Stop Script

  Usage:
    {0} start <name>   Start all instances with 'Name' tags that begin with <name>
    {0} stop <name>    Stop all instances with 'Name' tags that begin with <name>
    {0} toggle <name>  Toggle running state of all instances with 'Name' tags that begin with <name>
    {0} help           Show this help dialog
    {0} version        Display the script version
    '''.format(sys.argv[0])
    print(help_str)
    sys.exit()

elif cmd_name == 'VERSION':
    print(version)
    sys.exit()

else:
    print('Error: Unsupported command: {0}'.format(cmd_name))
    print()
    print(short_help)
    sys.exit(errno.EINVAL)

