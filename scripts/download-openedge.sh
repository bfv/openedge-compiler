
echo base: ${OPENEDGE_BASE_VERSION}
echo version: ${OPENEDGE_VERSION}

docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_VERSION}

if [[ "${OPENEDGE_VERSION}" > "12.8.3" ]]; then
  docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_VERSION}
  mv ${PWD}/src/PROGRESS_OE.tar.gz ${PWD}/src/PROGRESS_PATCH_OE.tar.gz
  docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_BASE_VERSION}
  ls -l ${PWD}/src
else 
  docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_VERSION}
fi
