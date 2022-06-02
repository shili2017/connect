#!/bin/bash

vlib work
vlog *.v *.sv
vsim -c -do "run -all" CONNECT_testbench_sample_peek_axi4
