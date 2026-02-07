#!/bin/bash
sleep 1
clear
echo -e               "####################################################################"
echo -e "#\033[1;39;44m     _  __               ____                                     \033[0m#"
echo -e "#\033[1;39;44m    / |/ /_ ____ _____  / __/__ _____  _____ _______  ___ __ __   \033[0m#"
echo -e "#\033[1;39;44m   /    / // /\ \ / _ \_\ \/ -_) __/ |/ / -_) __(_-<_/ -_) // /   \033[0m#"
echo -e "#\033[1;39;44m  /_/|_/\_, //_\_\​\___/___/\__/_/  |___/\__/_/ /___(_)__/\_,_/    \033[0m#"
echo -e "#\033[1;39;44m       /___/                                                      \033[0m#"
echo -e               "####################################################################"
COMMIT_NUMBER=$(cat /commit_count.txt)
COMMIT_MESSAGE=$(cat /commit_message.txt)
echo -e " "
echo -e "Server is starting... "
echo -e " "
echo -e "Runner version: v$COMMIT_NUMBER"
#echo -e "Developer message: $COMMIT_MESSAGE"
echo -e " "
# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

# Update ClamAV definitions (optional but recommended at runtime)
if [ "$ENABLE_AV" = 1 ]; then
	printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;44mAntivirus scanning is enabled. If youre restarting the server often, you can disable the antivirus for a while at Startup page\033[0m\n"
	mkdir -p /home/container/clamav/logs /home/container/clamav/quarantine
	if find /home/container/clamav/quarantine -type f | grep -q .; then
		if [ "$AUTOREMOVE" = 1 ]; then
			printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;41mQuarantined files are in /clamav/quarantine, Deleting...\033[0m\n"
			rm -rf /home/container/clamav/quarantine/*
		else
			printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;41mQuarantined files are in /clamav/quarantine, Please delete them to remove this error\033[0m\n"
			exit
		fi
	fi
	echo -e "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;44mUpdating Virus Databases...\033[0m"
	cp /freshclam.conf /home/container/clamav
	freshclam --config-file=/home/container/clamav/freshclam.conf
	if [ "$ONLY_PLUGINS" = 1 ]; then
		echo -e "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;44mScanning modules with ClamAV AntiVirus...\033[0m"
		echo -e "THIS MAY TAKE AROUND 2 MINUTES"
		clamscan -r --move=/home/container/clamav/quarantine --log=/home/container/clamav/logs/clamscan.txt --database=/home/container/clamav/ --infected --include="^[^\.]+$" --include="\.py$" --include="\.pyx$" --exclude-dir="\.cache"  /home/container/.local
	else
		echo -e "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;44mScanning the home directory with ClamAV AntiVirus...\033[0m"
		echo -e "THIS MAY TAKE UNDER 10 MINUTES"
		clamscan -r --move=/home/container/clamav/quarantine --log=/home/container/clamav/logs/clamscan.txt --database=/home/container/clamav/ --infected --include="^[^\.]+$" --include="\.py$" --include="\.pyx$" --exclude-dir="\.cache" /home/container
	fi
	if find /home/container/clamav/quarantine -type f | grep -q .; then
		if [ "$AUTOREMOVE" = 1 ]; then
			printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;41mQuarantined files are in /clamav/quarantine, Deleting...\033[0m\n"
			rm -rf /home/container/clamav/quarantine/*
		else
			printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;41mQuarantined files are in /clamav/quarantine, Please delete them to remove this error\033[0m\n"
			exit
		fi
	fi
else
	rm -rf /home/container/clamav
    printf "\033[1m\033[33mcontainer@nyxoservers.eu~ \033[1;39;44mWARNING: Antivirus scanning is disabled.\n"
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}