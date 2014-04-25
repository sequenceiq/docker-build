#!/bin/bash

: ${KEY?'missing github private key do deploy docker run -e KEY=XXXX'}

[ -n "$DEBUG" ] && echo debug on ... && set -x


# private github key comes from env variable KEY
# docker run -e KEY=XXXX
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# switch off debug to hide private key
set +x
echo $KEY|base64 -d> /root/.ssh/id_rsa
[ -n "$DEBUG" ] && echo debug on ... && set -x

chmod 600 /root/.ssh/id_rsa

# saves githubs host to known_hosts
ssh -T -o StrictHostKeyChecking=no  git@github.com

# repo clone URL comes from env variable REPO
# branch to build comes from env variable BRANCH
# e.g.: docker run -e REPO=git@github.com:sequenceiq/api.git -e BRANCH=master
git clone -b $BRANCH $REPO /tmp/prj

/tmp/prj/gradlew -b /tmp/prj/build.gradle clean build sonarRunner uploadArchives --refresh-dependencies --stacktrace
