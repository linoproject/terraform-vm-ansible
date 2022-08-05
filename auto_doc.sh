#!/bin/bash
terraform-docs markdown ./vm-azure/ > ./vm-azure/README.md
terraform-docs markdown ./main_azure/ > ./main_azure/README.md
terraform-docs markdown ./ansible/ > ./ansible/README.md

