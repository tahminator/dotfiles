pids=$(ps aux | grep GradleDaemon | grep -v grep | awk '{print $2}')
if [[ -z "$pids" ]]; then
	echo "No Gradle daemons running."
else
	echo "Killing Gradle daemons: $pids"
	echo "$pids" | xargs kill -9
	echo "Done."
fi
