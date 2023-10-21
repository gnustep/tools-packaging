#!/usr/bin/emv bash

# Import common variables and functions
source ${SCRIPT_DIR}/common.sh

# ARGUMENTS: $1 PROJECT_NAME
function downloadProjectWithName {
	local projectName=$1
	# TODO: Escape projectName before checking
	local conf="${SOURCE_DESC_DIR}/${projectName}.json"

	if test -d ${SOURCE_DIR}/${projectName}; then
		echo "INFO: Project '${projectName}' already exists."
		return 0
	fi

	
	if ! test -f $conf; then
		echo "ERROR: Could not find configuration '${conf}' for project '${projectName}'"
		return 1
	fi

	local type=$(cat ${conf} | jq -r .type)
	if test $type == "git"; then
		echo "INFO: Downloading git repository '${git}'..."
	fi

	local git=$(cat ${conf} | jq -r .git)
	local branch=$(cat ${conf} | jq -r .tag)

	git clone --recurse-submodules --depth 1 --branch ${branch} ${git} ${SOURCE_DIR}/${projectName}
	if test $? -ne 0; then
		echo "ERROR: Failed to clone git repository '${git}'"
		return 1
	fi

	return 0
}
