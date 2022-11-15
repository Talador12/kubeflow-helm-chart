#!/bin/bash

sed 's/{-/{{/'g | sed 's/-}/}}/g' <&0
