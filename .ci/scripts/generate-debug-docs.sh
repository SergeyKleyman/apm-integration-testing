#!/usr/bin/env bash
set -e

TYPE=${1:-"selector"}
gitUrl=$(git remote get-url origin)
commit=$(git rev-parse HEAD)

echo "Let's generate the details to help to reproduce it locally ..."
echo ""
echo ""

echo "# Let's clone the repo"
echo "git clone ${gitUrl} .apm-its"
echo "cd .apm-its"
echo "git checkout ${commit}"
echo ""

echo "# Let's run the apm-integration testing for ${NAME}"
echo "export ELASTIC_STACK_VERSION=${ELASTIC_STACK_VERSION}"
echo "export BUILD_OPTS=\"${BUILD_OPTS}\""
SCRIPT_NAME=$(echo "${INTEGRATION_TEST}" | tr '[:upper:]' '[:lower:]')
if [ "${TYPE}" == "selector" ] ; then
    if [ "${SCRIPT_NAME}" == "all" ] || [ "${SCRIPT_NAME}" == "opbeans" ] || [ "${SCRIPT_NAME}" == "ui" ] ; then
        echo ".ci/scripts/${SCRIPT_NAME}.sh"
    else
        echo ".ci/scripts/agent.sh ${NAME} ${APP}"
        if [ "${SCRIPT_NAME}" == "rum" ] ; then
            echo "# Build docker image with the new rum agent"
            echo "git clone https://github.com/elastic/opbeans-frontend.git .opbeans-frontend"
            echo "cd .opbeans-frontend"
            echo "VERSION=\${BUILD_OPTS/--rum-agent-branch /}"
            echo ".ci/bump-version.sh \${VERSION} false"
            echo 'make build'
            echo 'cd ..'
            echo "# Run opbeans rum"
            echo ".ci/scripts/opbeans-rum.sh"
        else
            echo ".ci/scripts/opbeans-app.sh ${NAME} ${APP} ${OPBEANS_APP}"
        fi
    fi
else
    echo ".ci/scripts/${NAME}.sh"
fi
echo ""
echo "make stop-env || echo 'Failed to stop the environment'"
echo ""
echo "ls -ltrh"
