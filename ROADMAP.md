# RoadMap

Topics in a very loose order of priority.

- ADD Logging
  - CloudWatch logging for storage
    - retention: 1yr
  - logrotate to contain disk usage
    - 1 day on the machine
    - no compressed archives

- Build base image using Packer
  - AMI configuration
  - Installed services
  - ready-to-go

- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes
