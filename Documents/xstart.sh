#!/bin/bash

id=$(xinput --list --id-only "Wacom HID 50F8 Finger touch")
xinput disable "$id"
id=$(xinput --list --id-only "Wacom HID 50F8 Pen eraser")
xinput disable "$id"
id=$(xinput --list --id-only "Wacom HID 50F8 Pen stylus")
xinput disable "$id"
