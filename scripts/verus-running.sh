#!/bin/bash

pidof verusd | awk 'BEGIN { n=0 } { if (NF>=1) n=NF} END { print n}'
