#!/bin/bash -ex

cd packer/
packer build -var-file=aws-var.json ami.json

#cd ../terrafom/

#terraform init

#terraform plan -var-file=variables.tfvars
