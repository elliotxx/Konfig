#!/usr/bin/env bash

# Copyright 2021 Alipay.com Inc.

set -o errexit
set -o nounset
set -o pipefail

WORKING_DIR=${WORKING_DIR:-"$PWD"}
BASE_PKG_DIR=${BASE_PKG_DIR:-"base/pkg"}
KCL_MOD_FILE=${KCL_MOD_FILE:-"kcl.mod"}
KCL_CACHE_FILE=${KCL_CACHE_FILE:-".kclvm"}
ENABLE_CACHE_FALSE=${ENABLE_CACHE_FALSE:-"false"}
ENABLE_CACHE_TRUE=${ENABLE_CACHE_TRUE:-"true"}
PKG_PREFIX_OLD=${PKG_PREFIX_OLD:-"base.pkg.kusion_kubernetes."}
PKG_PREFIX_NEW=${PKG_PREFIX_NEW:-"base.pkg."}
CHANGED_PROJECTS=${CHANGED_PROJECTS:-""}
OSS_ENDPOINT=${OSS_ENDPOINT:-""}
OSS_BUCKET=${OSS_BUCKET:-""}
OSS_ACCESS_KEY=${OSS_ACCESS_KEY:-""}
OSS_SECRET_KEY=${OSS_SECRET_KEY:-""}
OSS_CLOUD_URL="oss://${OSS_BUCKET}/gitops/app"

PROJECTS_NEED_MULTI_COMPILE=(
  "ant_sdn" "antvip" "sofamqbroker" "msgbroker" "sofaregistry" "zqueue" "antq" "zdrmdata" "cfzdrmdata" "sofagw" "antzproxy" "meshpilot" "meshapiserver" "spannercloud" "nfccoperator" "jobmeta"
  )

function is_included {
  for p in "${PROJECTS_NEED_MULTI_COMPILE[@]}"; do
    if [[ "$1" == "${p}" ]]; then
      return
    fi
  done
  return 1
}

if [[ -z "${CHANGED_PROJECTS}" ]]; then
  echo "CHANGED_PROJECTS is empty!"
  exit 0
fi

if [[ -z "${OSS_ENDPOINT}" || -z "${OSS_BUCKET}" || -z "${OSS_ACCESS_KEY}" || -z "${OSS_SECRET_KEY}" ]]; then
  echo "invalid OSS info!"
  exit 0
fi

prefix="/"

mkdir -p "/tmp/iac"

IFS=';' read -ra ADDR <<< "$CHANGED_PROJECTS"
for project in "${ADDR[@]}"; do
  if [[ -z "${project}" ]]; then
    continue
  fi
  IFS='#' read -ra tagWithPath <<< "$project"
  if [[ "${#tagWithPath[@]}" != 2 ]]; then
    continue
  fi
  tag=${tagWithPath[0]}
  projectPath=${tagWithPath[1]}

  # extract project name from projectPath
  projectName=$(echo ${projectPath} | rev | cut -d'/' -f 1 | rev)

  # remove prefix slash
  projectPathWithoutSlash=${projectPath/#$prefix}
  if [[ ! -d "${projectPathWithoutSlash}" ]]; then
    echo "project ${projectName} with path ${projectPathWithoutSlash} not exist, skip it"
    continue
  fi

  # pre-compile project for generate cache dir
  uploadFiles="${KCL_MOD_FILE} ${KCL_CACHE_FILE} ${projectPathWithoutSlash}"
  echo "handle IaC code of project ${projectName} with tag ${tag} and path ${projectPathWithoutSlash}"
  sed "s/$ENABLE_CACHE_FALSE/$ENABLE_CACHE_TRUE/g" "${KCL_MOD_FILE}" > "/tmp/kcl.mod"
  sed "s/$PKG_PREFIX_OLD/$PKG_PREFIX_NEW/g" "/tmp/kcl.mod" > "${KCL_MOD_FILE}"
  for dir in `ls ${projectPathWithoutSlash}`;
    do
      cd "${WORKING_DIR}"
      # clean old kclvm cache dir if exists
      if [ -d "${WORKING_DIR}/${KCL_CACHE_FILE}" ]; then
        echo "clean kclvm cache dir: ${WORKING_DIR}/${KCL_CACHE_FILE}"
        rm -rf "${WORKING_DIR}/${KCL_CACHE_FILE}"
      fi
      if [[ $dir != "base" && $dir != "crd" && -d "${projectPathWithoutSlash}/${dir}" ]]; then
        # pre compile in stack dir
        cd "${projectPathWithoutSlash}/$dir"
        echo "pre-compile IaC code of project ${projectName} with stackPath ${projectPathWithoutSlash}/$dir"
        kusion compile -Y "ci-test/settings.yaml" "kcl.yaml" -o "ci-test/stdout.golden.yaml"

        # append depended files of project to uploadFiles
        dependedFiles=$(kcl-go list-app --include-all --show-index=false --info=false)
        uploadFiles=$(echo ${dependedFiles} ${uploadFiles} | tr " " "\n")
        if is_included "${projectName}" ; then
          echo "project ${projectName} need to run multi compile"
          continue
        fi
        break
      fi
    done
  
  # tar and upload to oss
  cd "${WORKING_DIR}"

  # avoid to created hard-link when compress duplicated files with --hard-dereference,
  # otherwise, an error may be occur during decompression
  tar --ignore-failed-read --hard-dereference -zcvf "/tmp/iac/${tag}.tar.gz" ${uploadFiles} > /dev/null 2>&1
  ossutil64 cp /tmp/iac/${tag}.tar.gz "${OSS_CLOUD_URL}/${tag}/iac/files.tar.gz" --include "*.tar.gz" -e ${OSS_ENDPOINT} -i ${OSS_ACCESS_KEY} -k ${OSS_SECRET_KEY} -r -u -f
done
