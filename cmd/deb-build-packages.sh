#!/usr/bin/env bash
# Description: Build the deb packages from the source packages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import common variables and functions
source ${SCRIPT_DIR}/common.sh

# Import download functions
source ${SCRIPT_DIR}/download-repos.sh

# List of enabled packages in the correct build order
# (pbuilder is not able to resolve local dependencies automatically -_-)
#
# TODO: We might want to read out the dependencies from the debian control file
# and sort the packages accordingly
# This would allow us to have a functioning "--only" option that resolves
# all local dependencies automatically
source ${SCRIPT_DIR}/phases.sh

# List of available debian packages
# Populated by listSourcePackages
SOURCE_PKG_ARRAY=()

function refreshLocalPackageIndex {
    mkdir -p ${PBUILDER_RESULT}

    cd ${PBUILDER_RESULT}

    rm Packages
    rm Release

    dpkg-scanpackages . /dev/null > Packages
    if test $? -ne 0; then
        echo "ERROR: Failed to update local package index!"
        return 1
    fi
    apt-ftparchive release . > Release
    if test $? -ne 0; then
        echo "ERROR: Failed to create local package index!"
        return 1
    fi
}

# Initialise the pbuilder configuration and create the base tarball if it does not exist
function pbuilderInit {
    # Update local package index
    echo "INFO: Updating local package index..."
    if ! refreshLocalPackageIndex; then
        return 1
    fi
    if test $VERBOSE -eq 1; then
        echo "DEBUG: Using pbuilder configuration file ${PBUILDER_CONFIG}"
        echo "DEBUG: Using pbuilder arguments ${PBUILDER_DEFAULT_ARGS}"
    fi

    # Check if the base tarball exists
    if test -f ${PBUILDER_BASE_TGZ}; then
        if test $PBUILDER_SKIP_UPDATE -eq 1; then
            echo "INFO: Skipping base tarball update..."
            return 0
        fi
        echo "INFO: Base tarball already exists. Updating..."

        pbuilder update ${PBUILDER_DEFAULT_ARGS}
        if test $? -ne 0; then
            echo "ERROR: Failed to update the base tarball!"
            return 1
        fi
    else
        echo "INFO: Base tarball does not exist. Creating..."

        pbuilder create ${PBUILDER_DEFAULT_ARGS}
        if test $? -ne 0; then
            echo "ERROR: Failed to create the base tarball!"
            return 1
        fi

        # Add pinning of local repo
        pbuilder login ${PBUILDER_DEFAULT_ARGS} --save-after-login <<EOF
echo "Package: *" > /etc/apt/preferences.d/local-pin.pref
echo "Pin: origin \"\"" >> /etc/apt/preferences.d/local-pin.pref
echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/local-pin.pref
EOF

    fi

    return 0;
}

# ARGUMENTS: PACKAGE_NAME
function copyDebianDescriptionIntoTempDirectory {
    local pkgName=$1
    local sourceDir=${SOURCE_DEB_DIR}/${pkgName}
    local destDir=${SOURCE_TEMP_DEB_DIR}/${pkgName}

    if test ! -d ${SOURCE_TEMP_DEB_DIR} ; then
        echo "INFO: Creating temporary directory ${SOURCE_TEMP_DEB_DIR}..."
        mkdir -p ${SOURCE_TEMP_DEB_DIR}
        if test $? -ne 0; then
            echo "ERROR: Failed to create temporary directory ${SOURCE_TEMP_DEB_DIR}!"
            return 1
        fi
    fi

    if test ! -d ${sourceDir}; then
        echo "ERROR: Source directory ${sourceDir} does not exist!"
        return 1
    fi

    # Copy the debian directory into the temp directory if not present
    if test ! -d ${destDir}; then
        echo "INFO: Copying debian directory from ${sourceDir} to ${destDir}..."
        cp -r ${sourceDir} ${destDir}
        if test $? -ne 0; then
            echo "ERROR: Failed to copy debian directory from ${sourceDir} to ${destDir}!"
            return 1
        fi
    fi

    return 0;
}

# pdebuild requires PKGNAME_VERSION.orig.tar.gz tarballs
# This function MUST be called after copyDebianDescriptionIntoTempDirectory
# ARGUMENTS: PACKAGE_NAME
function makeSourceTarball {
    local pkgName=$1
    local debDir=${SOURCE_TEMP_DEB_DIR}/${pkgName}/debian
    local sourceDir=${SOURCE_TEMP_DIR}/${pkgName}

    if test ! -d ${sourceDir}; then
        echo "ERROR: Source directory ${sourceDir} does not exist!"
        return 1
    fi
    if test ! -d ${debDir}; then
        echo "ERROR: Debian directory ${debDir} does not exist!"
        return 1
    fi

    local version=$(dpkg-parsechangelog -l ${debDir}/changelog | grep Version | cut -d' ' -f2 | cut -d'-' -f1)
    if test -z ${version}; then
        echo "ERROR: Failed to parse version from changelog!"
        return 1
    fi

    local tarballName=${pkgName}_${version}.orig.tar.gz

    echo "INFO: Creating source tarball ${tarballName}..."
    # Create the source tarball without version control files
    tar -czf ${SOURCE_TEMP_DEB_DIR}/${tarballName} --exclude-vcs -C ${sourceDir} .
    if test $? -ne 0; then
        echo "ERROR: Failed to create source tarball ${tarballName}!"
        return 1
    fi
}

# Arguments: PACKAGE_LOCATION DESTINATION NAME
function buildSourcePackage {
    local PACKAGE_LOCATION=$1
    local DESTINATION=$2
    local NAME=$3

    echo "INFO: Building source package ${NAME}..."
    # Copy the debian directory into the temp directory if not present
    copyDebianDescriptionIntoTempDirectory ${NAME}

    echo "INFO: Preparing package ${NAME} found at location ${SOURCE_TEMP_DEB_DIR}/${NAME}"

    # Check if the package location exists
    if test ! -d ${PACKAGE_LOCATION}; then
        echo "ERROR: Package location ${PACKAGE_LOCATION} does not exist!"
        return 1
    fi

    # Check if the source tarball exists in temp dir
    if test ! -f ${SOURCE_TEMP_DEB_DIR}/${NAME}*.orig.tar.gz; then
        echo "INFO: Source tarball ${SOURCE_TEMP_DEB_DIR}/${NAME}*.orig.tar.gz does not exist. Creating..."
        if ! makeSourceTarball ${NAME}; then
            echo "ERROR: Failed to create source tarball ${SOURCE_TEMP_DEB_DIR}/${NAME}*.orig.tar.gz!"
            return 1
        fi
    fi

    # Extract the source tarball into the temporary directory
    echo "INFO: Extracting source tarball ${SOURCE_TEMP_DEB_DIR}/${NAME}*.orig.tar.gz into ${SOURCE_TEMP_DEB_DIR}/${NAME}..."
    tar -xzf ${SOURCE_TEMP_DEB_DIR}/${NAME}*.orig.tar.gz -C "${SOURCE_TEMP_DEB_DIR}/${NAME}"

    # Check if we should continue building the package
    if test $EXTRACT_ONLY -ne 0; then
        echo "Skipping build process as EXTRACT_ONLY is specified!"
        return 0
    fi


    # Build the package
    echo "INFO: Building package ${NAME} from source with pdebuild..."

    cd ${SOURCE_TEMP_DEB_DIR}/${NAME}

    if test "${NO_SANDBOX}" -eq 1; then
        # Install build dependencies
        mk-build-deps --install --remove --tool='apt-get -y --no-install-recommends' debian/control
        # Remove left-overs
        rm *.buildinfo *.changes
    fi

    # Configure the package and generate a .dsc file
+    dpkg-source --build .

    if test "${NO_SANDBOX}" -eq 1; then
        # Use debuild and skip signing as we later sign the Release file
        # from the mirror
        debuild -us -uc
        if test $? -ne 0; then
            echo "ERROR: debuild for package ${NAME} failed!"
            return 1
        fi

        # We need to install the generated packages after building
        # as other phases may depend on this phase
        echo "INFO: Installing package ${NAME} via dpkg"

        # Parse installation order from our JSON description file
        local descFile="${SOURCE_DESC_DIR}/${NAME}.json"

        # Parse installation_order string array and get files
        local debs=$(cat ${descFile} | jq -r '.installation_order[]' | xargs -I{} find .. -name '{}')
        dpkg -i ${debs}
    else
        # Use pbuilder to build the package in a sandbox with our custom
        # pbuilder configuration
        # 
        # Using pdebuild does not work as the pdebuild script checks for missing
        # dependencies with dpkg-checkbuilddeps on the HOST system!
        # This means we need to install the dependencies on the host system aswell
        # which is rediculous.
        pbuilder build  ${PBUILDER_DEFAULT_ARGS} ../${NAME}*.dsc
        if test $? -ne 0; then
            echo "ERROR: Failed to build package ${NAME}!"
            return 1
        fi
    fi
}

# Create a list of available source packages
function listSourcePackages {
    DIRS_LIST=$(find ${SOURCE_DEB_DIR} -maxdepth 1 -type d -not -path ${SOURCE_DEB_DIR})

    IFS=$'\n' # Set IFS to newline for splitting DIRS_LIST into array
    SOURCE_PKG_ARRAY=($DIRS_LIST) # Split DIRS_LIST into array
    unset IFS # Reset IFS back to its original value

    echo "INFO: Found ${#SOURCE_PKG_ARRAY[@]} source packages"
    # Only print the list of packages if verbose mode is enabled
    if test $VERBOSE -eq 1; then
        for dir in "${SOURCE_PKG_ARRAY[@]}"; do
            echo "  - $(basename "$dir")"
        done
    fi
}

# ARGUMENTS: PACKAGE_NAME
function findSourcePackage {
    local PACKAGE_NAME=$1

    for entry in "${SOURCE_PKG_ARRAY[@]}"; do
        if test "$(basename "$entry")" == "${PACKAGE_NAME}"; then
            echo "INFO: Found source package ${PACKAGE_NAME}!"
            echo "INFO: Building source package ${phase}..."

            if ! buildSourcePackage "${SOURCE_TEMP_DIR}/${phase}" "${PBUILDER_RESULT}" "${phase}"; then
                echo "ERROR: Failed to build source package ${phase}!"
                return 1
            fi
            return 0
        fi
    done
    return 1
}

function buildPackages {
    if test "$SKIP_PBUILDER_INIT" -eq 0; then
        if ! pbuilderInit ; then
            echo "ERROR: Failed to initialize pbuilder!"
            return 1
        fi
    fi

        # Get a list of all debian package configurations
    listSourcePackages

    for phase in "${BUILD_PHASES_ARRAY[@]}"; do
        # Check if the package should be skipped
        if test -n "${ONLY_PKG}"; then
            if test "${phase}" != "${ONLY_PKG}"; then
                echo "INFO: Skipping package ${phase}..."
                continue
            fi
        fi

        # Download source if not already downloaded
        downloadProjectWithName "${phase}"
        if test $? -ne 0; then
            return 1
        fi

        # Check if the package is a source package
        if ! findSourcePackage "${phase}"; then
            echo "ERROR: Failed to find package ${phase}!"
            return 1
        fi
    done


    return 0
}