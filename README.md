# Satisfactory Dedicated Server

TODO:

must

- ec2 instance - DONE
  - req. packages
  - EBS = 64Gb
  - MEM = 12G
  - CPU = ?
  - static IP

Goal: just get it to work

should

- startup script to keep OS and service updated - DONE
- log rotation - DONE
- systemd service - DONE
- save game data to a EBS vol that is mounted @ startup - DONE

nice

- DNS to satisfactory.davidjeddy.com - DONE
- separate IAM user and roles for Satisfactory resources
