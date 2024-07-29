#!/bin/bash

id=$(xinput --list --id-only "Wacom HID 50F8 Finger touch")
xinput disable "$id"
