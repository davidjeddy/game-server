# RoadMap

Topics in a very loose order of priority.

- ADD Logging
  - CloudWatch logging for storage
    - retention: 1yr
  - logrotate to contain disk usage
    - 1 day on the machine
    - no compressed archives

- Satisfactory game files (~/satisfactory) stored on an EBS

- Build base image using Packer
  - AMI configuration
  - Installed services
  - ready-to-go

- Bastion host for non application ingress

- Load balancer in front of EC2 instances for better traffic and routing management

- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes
