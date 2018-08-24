#!/bin/bash

TF_LOG=WARN
cd ./Launch-Template
~/terraform init
~/terraform destroy -auto-approve
~/terraform apply -auto-approve


