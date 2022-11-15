#################################################################################
# FUNCTIONS                                                                     #
#################################################################################
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))
CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(shell cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

#################################################################################
# GLOBALS                                                                       #
#################################################################################

# Variables
DATE := $(shell date '+%Y.%m.%d')
USER := $(shell whoami)

$(info ----- make ${MAKECMDGOALS} -----)

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Builds a helm chart from kubeflow manifests
build:
#	rm -rf kubeflow/templates/*
	kustomize build --helm-command helm -o kubeflow/templates .
<<<<<<< HEAD
	helm template kubeflow/
=======
# find kubeflow/templates/. -type f -exec sed -i '' -e 's/{{/{-/g' {} +
# find kubeflow/templates/. -type f -exec sed -i '' -e 's/}}/-}/g' {} +
# helm template kubeflow/
>>>>>>> e9509811b8d76925485aee78bbf459d8004c407b

## Initializes this repository
init:
	git submodule init
	git submodule update

## generate docker images within "platform/images/`
generate-images:
	cd images && ./generate.sh

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################
.DEFAULT_GOAL := help
.PHONY: help check-ns

# Checks to see if the NS parameter is defined, used to limit certain commands to specific namespaces only
check-ns:
ifndef NS
	$(error NS parameter 'namespace' is undefined. Required format: [ make ${MAKECMDGOALS} NS= ])
endif

help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
