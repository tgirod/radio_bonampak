#!/bin/bash

mpv --no-video --quiet --loop-playlist --shuffle --jack-name="radio_de" --jack-port="SuperCollider:in_1" ./radio_de/* &
mpv --no-video --quiet --loop-playlist --shuffle --jack-name="radio_fr" --jack-port="SuperCollider:in_2" ./radio_fr/* &
mpv --no-video --quiet --loop-playlist --shuffle --jack-name="radio_us" --jack-port="SuperCollider:in_3" ./radio_us/* &

