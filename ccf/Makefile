export
SHELL := /bin/bash

NODE_ADDRESS ?= localhost:8080
CCF_VERSION ?= 5.0.0-dev10
CCF_PLATFORM ?= virtual
TAG ?= latest

SERVICE_CERT := $(shell awk 'ORS=(NR>1 && /^$$/)?"" : "\\n"' certs/service_cert.pem)
MEMBER0_ID := $(shell cat certs/member0_id)
MEMBER_CERT=$(shell awk 'ORS=(NR>1 && /^$$/)?"" : "\\n"' certs/member0_cert.pem)

network-start:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/network_start.sh

network-stop:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/network_stop.sh

network-open:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/network_open.json

user-add:
	@echo -e "\e[34m$@\e[0m" || true
	echo tbd

member-add:
	@echo -e "\e[34m$@\e[0m" || true
	echo tbd

member-activate:
	@echo -e "\e[34m$@\e[0m" || true
	MSG_TYPE=state_digest METHOD=POST ./scripts/endpoint_call.sh \
		gov/members/state-digests/${MEMBER0_ID}:update?api-version=2023-06-01-preview | tail -n 1 > /tmp/request.json
	MSG_TYPE=ack CONTENT_PATH=/tmp/request.json METHOD=POST ./scripts/endpoint_call.sh \
		gov/members/state-digests/${MEMBER0_ID}:ack?api-version=2023-06-01-preview

app-deploy:
	@echo -e "\e[34m$@\e[0m" || true
	./scripts/proposal_submit.sh proposals/app_deploy.json