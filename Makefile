# Keep this stack list in sync with .github/workflows/terraform.yml.
TERRAFORM ?= terraform
STACKS := simple_server \
	multiserver_loadbalancer \
	remote_state/remote_state_store \
	remote_state/launch_config \
	remote_state/autoscaling_loadbalancing

.PHONY: fmt fmt-check validate lock

fmt:
	$(TERRAFORM) fmt -recursive

fmt-check:
	$(TERRAFORM) fmt -check -recursive -diff

validate:
	@set -eu; \
	for stack in $(STACKS); do \
		echo "==> $$stack"; \
		$(TERRAFORM) -chdir="$$stack" init -backend=false -input=false; \
		$(TERRAFORM) -chdir="$$stack" validate; \
	done

lock:
	@set -eu; \
	for stack in $(STACKS); do \
		echo "==> $$stack"; \
		$(TERRAFORM) -chdir="$$stack" providers lock \
			-platform=linux_amd64 \
			-platform=linux_arm64 \
			-platform=darwin_amd64 \
			-platform=darwin_arm64 \
			-platform=windows_amd64; \
	done
