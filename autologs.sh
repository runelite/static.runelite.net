#!/bin/bash

CLIENT_PATH="$HOME/.runelite/logs/client.log"
LAUNCHER_PATH="$HOME/.runelite/logs/launcher.log"

if [[ ! -f $CLIENT_PATH ]]; then
    echo "client.log not found."
    exit -1
fi

if [[ ! -f $LAUNCHER_PATH ]]; then
    echo "launcher.log not found."
    exit -1
fi

curl -F "file[0]=@$CLIENT_PATH" -F "file[1]=@$LAUNCHER_PATH" https://api.runelite.net/autologs
