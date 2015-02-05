Satellite - Infrastructure
---

The main goal of this document is to outline all infrastructure rules and access we got for this project. Anything which has been created,updated,deleted must be added in this document.

### Network:

+ VPC: vpc-a88763cd
+ Subnet: subnet-0ef0dc48
+ Public IP: 54.186.1.206 
+ Public DNS: ec2-54-186-1-206.us-west-2.compute.amazonaws.com

### SSH Access:

+ PEM file: 04-Infrastructure/02-SSH/satellitejf14.pem
+ Execute on your Terminal Application 

        cp satellitejf14.pem ~/.ssh/  
        chmod 400 ~/.ssh/satellitejf14.pem
        ssh -i ~/.ssh/satellitejf14.pem ec2-user@54.186.1.206 (Satellite Machine)

### Database Access:

It'll only be accessible through loopback interface.

+ For root user

        User: root
        Password: Loducca#2014!@#$

+ For application user

        User: satellite
        Password: satjf14#2014!@#$



