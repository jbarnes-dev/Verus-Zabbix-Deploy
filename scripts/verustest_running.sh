#!/bin/bash

if ps faux | grep "[v]erusd -chain=vrsctest" > /dev/null;
then
	echo 1
else
	echo 0
fi
