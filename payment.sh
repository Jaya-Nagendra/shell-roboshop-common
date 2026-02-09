#!/bin/bash

source ./common.sh
app_name=payment

check_root
app_setup
python_sepup
systemd_setup
print_total_time