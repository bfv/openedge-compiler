@echo off

docker run -it ^
    -v c:/docker/_ftm/compiler/src:/app/src ^
    -v c:/docker/_ftm/compiler/artifacts:/artifacts ^
    -v c:/docker/_ftm/compiler/progress-4gldevsys.cfg:/usr/dlc/progress.cfg ^
    openedge-compiler ^
    /app/src/scripts/build.sh
