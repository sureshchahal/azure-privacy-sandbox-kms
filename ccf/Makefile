export
SHELL := /bin/bash

NODE_ADDRESS ?= localhost:8000
CCF_VERSION ?= 5.0.0-dev10
CCF_PLATFORM ?= virtual
TAG ?= latest

SERVICE_CERT := $(shell awk 'ORS=(NR>1 && /^$$/)?"" : "\\n"' certs/service_cert.pem)
CONSTITUTION := "$(shell curl -k https://localhost:8080/gov/service/constitution?api-version=2023-06-01-preview --silent | jq -Rs | sed 's/\(.*\)"/\1/' | sed 's/"//')$(shell cat ../governance/constitution/* | jq -Rs | sed 's/\(.*\)"/\1/' | sed 's/"//')"

id-of:
	@openssl x509 -in $(member) -noout -fingerprint -sha256 \
		| cut -d "=" -f 2 \
		| sed 's/://g' \
		| awk '{print tolower($$0)}'

certs-gen:
	@echo -e "\e[34m$@\e[0m" || true
	NAME=$(for) docker compose run keygenerator

network-local-start:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/network_local_start.sh

network-local-stop:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/network_local_stop.sh

network-deploy:
	@echo -e "\e[34m$@\e[0m" || true
	az deployment group create \
		--name $(name) \
		--resource-group ${RESOURCE_GROUP} \
		--template-file ccf.bicep \
		--parameters ccf.bicepparam

network-open:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/network_open.json

user-add:
	@echo -e "\e[34m$@\e[0m" || true
	echo tbd

member-add:
	@echo -e "\e[34m$@\e[0m" || true
	MEMBER_CERT="$(shell awk 'ORS=(NR>1 && /^$$/)?"" : "\\n"' $(member)_cert.pem)\n" \
	MEMBER_PUB_KEY="$(shell awk 'ORS=(NR>1 && /^$$/)?"" : "\\n"' $(member)_enc_pubk.pem)\n" \
	./scripts/proposal_submit.sh proposals/member_add.json

member-activate:
	@echo -e "\e[34m$@\e[0m" || true
	MSG_TYPE=state_digest METHOD=POST MEMBER=$(member) ./scripts/endpoint_call.sh \
		gov/members/state-digests/$(shell make id-of member=$(member)_cert.pem):update?api-version=2023-06-01-preview | tail -n 1 > /tmp/request.json
	MSG_TYPE=ack CONTENT_PATH=/tmp/request.json METHOD=POST MEMBER=$(member) ./scripts/endpoint_call.sh \
		gov/members/state-digests/$(shell make id-of member=$(member)_cert.pem):ack?api-version=2023-06-01-preview

app-deploy:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/app_deploy.json

constitution-get:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/endpoint_call.sh gov/service/constitution?api-version=2023-06-01-preview

constitution-update:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/constitution_set.json

key-release-policy-add:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/key_release_policy_add.json