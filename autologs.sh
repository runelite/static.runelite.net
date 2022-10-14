#!/usr/bin/env bash

LOG_DIR="$HOME/.runelite/logs"

# snap uses a different directory as its `$HOME`
if [[ ! -d $LOG_DIR ]]; then
	LOG_DIR="$HOME/snap/runelite/common/.runelite"
fi

if [[ ! -f $LOG_DIR/launcher.log ]]; then
	echo "Could not find launcher.log."
	exit 1
fi

declare -a upload_files

upload_files+=( "$LOG_DIR/launcher.log" )
[[ -f $LOG_DIR/client.log ]] && upload_files+=( "$LOG_DIR/client.log" )

MAX_CRASH_FILE_AGE="$(( 24 * 60 * 60 ))" # 1 day
MAX_JVM_CRASH_FILES=5
num_jvm_crash_files=0
CRASH_FILES=`find "$LOG_DIR" -mtime -1 -type f -name "jvm_crash_*"`
for crash_file in $CRASH_FILES; do
	if [[ "$num_jvm_crash_files" -ge "$MAX_JVM_CRASH_FILES" ]]; then
		break
	fi
	upload_files+=( "$crash_file" )
	(( num_jvm_crash_files++ ))
done

echo "Uploading the following files:"
upload_files_length="${#upload_files[@]}"
upload_flags=()
for (( i=0; i<upload_files_length; i++ )); do
	echo "${upload_files[i]}"
	upload_flags+=( -F "file[${i}]=@${upload_files[i]}" )
done

curl -s "${upload_flags[@]}" https://api.runelite.net/autologs > /dev/null
