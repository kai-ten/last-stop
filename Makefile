####################
# Init Environment #
####################

init: init-backend init-services

init-backend:
	cd iac/remote-backend && \
	terraform init && \
	terraform apply -auto-approve && \
	cd -

init-services:
	cd iac/service && \
	terraform init && \
	terraform apply -auto-approve

#################
# Plan Services #
#################

plan:
	cd iac/service && \
	terraform plan

###################
# Deploy Services #
###################

apply:
	cd iac/service && \
	terraform apply -auto-approve

###############
# Destroy App #
###############

destroy:
	cd iac/service && \
	terraform destroy -auto-approve
