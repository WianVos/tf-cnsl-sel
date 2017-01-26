include .source_env
CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef



TF_Version = 0.8.2
ENV_NAME = "deathstar"

check_env:
ifndef AWS_SECRET_KEY
	$(error AWS_SECRET_KEY is undefined)
endif
ifndef AWS_ACCESS_KEY
	$(error AWS_ACCESS_KEY is undefined)
endif


terraform/all: terraform/install terraform/keygen terraform/run_janeway terraform/clean

terraform/install:
	$(call chdir)
	if [ ! -f "./terraform" ]; then \
		/usr/bin/curl https://releases.hashicorp.com/terraform/$(TF_Version)/terraform_$(TF_Version)_darwin_amd64.zip > terraform.zip; \
		/usr/bin/unzip terraform.zip; \
		/bin/rm -f terraform.zip; \
	fi


terraform/keygen:
	$(call chdir)
	if [ ! -d "./environments/$(ENV_NAME)/ssh_keys" ]; then \
        /bin/mkdir ./environments/$(ENV_NAME)/ssh_keys; \
	fi
	if [ ! -f "./environments/$(ENV_NAME)/ssh_keys/rsa" ]; then \
		/usr/bin/ssh-keygen -b 2048 -t rsa -f ./environments/$(ENV_NAME)/ssh_keys/rsa -q -N ""; \
	fi


terraform/clean:
	$(call chdir)
	if [ -f ./environments/$(ENV_NAME)/terraform.tfstate ]; then \
		git reset HEAD ./environments/$(ENV_NAME)/terraform.tfstate; \
		rm -rf ./.terraform/modules/*; \
	fi

terraform/get:
	$(call chdir)
	if [ -f ./environments/$(ENV_NAME)/terraform.tfstate ]; then \
		git checkout ./environments/$(ENV_NAME)/terraform.tfstate; \
		./terraform get --update; \
	fi

terraform/plan:
	$(call chdir)
	./terraform plan -state=./environments/$(ENV_NAME)/terraform.tfstate -var aws_access_key=$(AWS_ACCESS_KEY) -var aws_secret_key=$(AWS_SECRET_KEY) ./environments/$(ENV_NAME)/
	git status	echo "No changes should exist in this repo."

terraform/apply: check_env
	$(call chdir)
	if [ ! -f ./environments/$(ENV_NAME)/terraform.tfstate ]; then \
	  ./terraform apply -no-color -parallelism=3 -var aws_access_key=$(AWS_ACCESS_KEY) -var aws_secret_key=$(AWS_SECRET_KEY)  ./environments/$(ENV_NAME)/; \
		fi
	./terraform apply -no-color -parallelism=3 -var aws_access_key=$(AWS_ACCESS_KEY) -var aws_secret_key=$(AWS_SECRET_KEY)  -state=./terraform.tfstate ./environments/$(ENV_NAME)/
	git add .
	git commit -m "Makefile) Terraform Apply, syncing terraform.tfstate"
	git push

terraform/destroy: check_env
	$(call chdir)
	if [ ! -f ./terraform.tfstate ]; then \
	  ./terraform destroy -no-color -parallelism=3 -var aws_access_key=$(AWS_ACCESS_KEY) -var aws_secret_key=$(AWS_SECRET_KEY) ./environments/$(ENV_NAME)/; \
		fi
	./terraform destroy -force -no-color -parallelism=3 -var aws_access_key=$(AWS_ACCESS_KEY) -var aws_secret_key=$(AWS_SECRET_KEY)  -state=./terraform.tfstate ./environments/$(ENV_NAME)/
	git add .
	git commit -m "Makefile) Terraform Apply, syncing terraform.tfstate"
	git push

tfplan: | tfsetup terraform/clean terraform/get terraform/plan
tfapply: | tfsetup terraform/clean terraform/get terraform/apply
tfdestroy: | tfsetup terraform/clean terraform/get terraform/destroy
tfsetup: | terraform/install terraform/keygen
tfrecycle: | terraform/destroy terraform/apply
