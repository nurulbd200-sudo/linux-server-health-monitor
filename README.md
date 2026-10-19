# Linux Server Health Monitor

A Bash script that monitors basic Linux server health and records the results in a log file.

## Features

* Monitor CPU usage
* Monitor memory usage
* Monitor disk usage
* Display system load average
* Display system uptime
* Log health reports with timestamps
* Schedule automatic checks using cron
* Rotate and compress logs using logrotate

## Requirements

* Linux (Ubuntu)
* Bash
* cron
* logrotate
* Git

## Installation

Clone the repository:

git clone https://github.com/nurulbd200-sudo/linux-server-health-monitor.git
cd linux-server-health-monitor

## Usage

Run the health check:

bash health_check.sh

Display help:

bash health_check.sh --help
```

## Log File

Health reports are stored in:

```text
logs/health.log
```

## Automation

Cron can run the health check every five minutes:

```cron
*/5 * * * * /bin/bash /home/ubuntu/linux-server-health-monitor/health_check.sh
```

## Log Rotation

Logrotate manages log rotation, compression, and retention. The configuration is located at:

```text
/etc/logrotate.d/server-health-monitor
```

## Technologies

* Bash scripting
* Linux
* Cron
* Logrotate
* Git and GitHub

## Author

Nurul Islam

