#!/usr/bin/python3

import sys
import boto3
import errno
import pprint

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

# Check for the correct number of arguments
if num_args > 3:
    err_num_args()

elif num_args >= 2:
    cmd_name = sys.argv[1].upper()

    if cmd_name == 'HELP':
        help_str = '''
      RHC AWS EC2 Instance Info Script

      Usage:
        {0}                Get a list of instances in the current region
        {0} filter <name>  Filter by 'Name' tags that begin with <name>
        {0} help           Show this help dialog
        {0} version        Display the script version
        '''.format(sys.argv[0])
        print(help_str)
        sys.exit()

    # Use the filter() method of the instances collection to retreive
    # all running EC2 instances.
    elif cmd_name == 'FILTER':
        if num_args == 3:
            filter_str = sys.argv[2]
        else:
            err_num_args()

        ec2 = boto3.resource('ec2')

        instances = ec2.instances.filter(
                #Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}])
                #Filters=[{'Name': 'tag:Name', 'Values': ['jmanning-ocp-master', 'jmanning-ocp-node']}])
                Filters=[{'Name': 'tag:Name', 'Values': [filter_str + '*']}])

    elif cmd_name == 'VERSION':
        print(version)
        sys.exit()

    else:
        print('Error: Unsupported command: {0}'.format(cmd_name))
        print()
        print(short_help)
        sys.exit(errno.EINVAL)

else:
    ec2 = boto3.resource('ec2')

    instances = ec2.instances.filter(
            Filters=[{'Name': 'tag:Name', 'Values': ['*']}])

# PrettyPrinter (pprint module) is used to break the 'Tags' list of objects onto multiple lines 
pprt = pprint.PrettyPrinter(indent=2)

# The "main" loop where we print out the list of Instances
for instance in instances:
    instance_tags_fmt = pprt.pformat(instance.tags)
    print('Instance ID: ', instance.id, '\n',
            'Instance Type: ', instance.instance_type, '\n',
            'Public DNS Name: ', instance.public_dns_name, '\n',
            'Public IP Address: ', instance.public_ip_address, '\n',
            'Tags: ', instance_tags_fmt, '\n',
            'State: ', instance.state, '\n\n')
    #print(instance)
