# progressive-siege
Incrementally siege a website

## Options
Mandatory options:
```
	-s	--steps		Number of concurrent users to be simulated at each step. Ex: "50,100,500,1000"
	-u	--url		URL to siege
```

Optionnal options:
```
	-t	--time		Time of each step. Ex: "2M", "1H". Tied to siege's time. Default: "5M"
	-d	--delay		delay between each simulated user request. Tied to siege's delay. Default: "0.5"
	-V	--siege-verbose	Enable siege's verbose mode. Default: not verbose
		--ulimit	Force ulimit's open file value (ulimit -n value). Default: ulimit's default (1024)
```

## Examples

  Run with 10, 20, 30, 40, 50 and 100 users, during 2 minutes each time (12 minutes in total)
```
    ./progressive-siege -u https://www.example.com --time 2M --steps 10,20,30,40,50,100
```

  Run with 50, 100, 150 and 200 users, during 5 minutes each time (20 minutes in total) with 20 secondes between each users's request. Forcing ulimit open files to 8192:
```
    ./progressive-siege -u https://beta.example.com --time 5M --steps 50,100,150,200 --delay 20 --ulimit 8192
```

## Nota

Some options cannot be chnged with siege's cli options. The configuration file may needs to be adjusted.


## More than 1023 connections

It may be tricky to run more than 1023 connections, event with a modified `limit` value and a bigger `ulimit -n` value.

The best solution may be to use tmux, open several panes, synchonise then with `:set synchronize-panes` and run the script in parallel.

