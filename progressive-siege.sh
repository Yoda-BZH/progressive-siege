#!/usr/bin/env bash

OPTS=$(getopt -o hvs:t:u:Vd: -l help,verbose,steps:,time:,url:,siege-verbose,delay:,ulimit: -- "$@")
eval set -- "$OPTS"

steps=""
verbose=0
time="5M"
delay="0.5"
siege="siege"
url=""
siege_verbose=""
val_ulimit=""

say_verbose() {
	if [ $verbose -eq 0 ]
	then
		return
	fi
	txt="$1"
	now=$(date --rfc-3339=seconds)

	echo "[$now] $txt"
}

say_help() {
	cat << EOF
Usage: ./progressive-siege.sh <-u|--url url> <-s|--steps steps> [-v|--verbose] [-t|--time time] [-d|--delay delay] [-V|--siege-verbose] [--ulimit ulimit]

Mandatory options:
	-s	--steps		Number of concurrent users to be simulated at each step. Ex: "50,100,500,1000"
	-u	--url		URL to siege

Optionnal options:
	-t	--time		Time of each step. Ex: "2M", "1H". Tied to siege's time. Default: "$time"
	-d	--delay		delay between each simulated user request. Tied to siege's delay. Default: "$delay"
	-V	--siege-verbose	Enable siege's verbose mode. Default: not verbose
		--ulimit	Force ulimit's open file value (ulimit -n value). Default: ulimit's default ($(ulimit -n))

Usage examples:

  Run with 10, 20, 30, 40, 50 and 100 users, during 2 minutes each time (12 minutes in total)
    ./progressive-siege -u https://www.example.com --time 2M --steps 10,20,30,40,50,100

  Run with 50, 100, 150 and 200 users, during 5 minutes each time (20 minutes in total) with 20 secondes between each users's request. Forcing ulimit open files to 8192:
    ./progressive-siege -u https://beta.example.com --time 5M --steps 50,100,150,200 --delay 20 --ulimit 8192

EOF

}

while true
do
	case "$1" in
		-h|--help)
			say_help
			shift
			exit 0
			;;
		-v|--verbose)
			verbose=1
			shift
			;;
		-s|--steps)
			steps="$2"
			shift 2
			;;
		-t|--time)
			time="$2"
			shift 2
			;;
		-u|--url)
			url="$2"
			shift 2
			;;
		-d|--delay)
			delay="$2"
			shift 2
			;;
		-V|--siege-verbose)
			siege_verbose="--verbose"
			shift
			;;
		--ulimit)
			val_ulimit="$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		*)
			echo "Unknown option '$1'"
			exit 1
			;;
	esac
done

if [ -z "$url" ]
then
	echo "No url provided, use -u|--url https://example.com"
	exit 1
fi

if [ -z "$steps" ]
then
	echo "No steps provided, use -s|--steps 5,10,50,100,500,1000"
	exit 1
fi

if [ -z "$time" ]
then
	echo "No time specified, use -t|--time 5m"
	exit 1
fi

if [ -n "$val_ulimit" ]
then
	say_verbose "Setting ulimit to $val_ulimit, per user request"
	ulimit -n "$val_ulimit"
	ulimit -a
fi

say_verbose "Starting a siege against $url"
say_verbose "Steps: $steps for $time"
IFS=","
for step in $steps
do
	say_verbose "Siege: $url for $time at $step"
	$siege --delay="$delay" --concurrent="$step" --time="$time" "$siege_verbose" "$url"
	ret_siege=$?
	if [ $ret_siege -ne 0 ]
	then
		echo "An error occured in siege, stopping"
		exit 1
	fi
done



