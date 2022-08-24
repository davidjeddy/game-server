# RoadMap

Topics in a very loose order of priority.

- Add Factorio
 - https://wiki.factorio.com/Multiplayer
 - https://gist.github.com/othyn/e1287fd937c1e267cdbcef07227ed48c
 - https://github.com/Bisa/factorio-init

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

- Bastion host for non application ingress

- Load balancer in front of EC2 instances for better traffic and routing management

- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes
