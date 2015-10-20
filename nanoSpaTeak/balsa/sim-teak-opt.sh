#!/bin/sh

DO_COMPILE=yes
if [ $# != 0 ]; then
	if [ $1 = "no-compile" ]; then
		DO_COMPILE=no
	fi
fi

set -xe

for file in memoryDualPort.v dummyCoproIrqFiq.v; do
	rm -f ${file}
	ln -s ../tests/${file} ${file}
done

#OPTS="-O -q stom"
#OPTS="-O -q svrr"
OPTS="-O"
# LATCHES="--latches l1:v1:o1:i1:b1:g1:f1:t1"
LATCHES="-L -l loop=1"

if [ ${DO_COMPILE} = yes ]; then
	rm -f teak-unlatched.teak teak.v

	teak -v ${OPTS} -t _spaHarvard_V5T -o teak-unlatched nanoSpaHarvard_deparameterised &&
	teak -v --gates --test-protocol ${LATCHES} -n teak-unlatched.teak -o teak
fi

RUNTIME=`teak-config`/share/teak/runtime/verilog

EXAMPLE_CELLS=${RUNTIME}/example.v
source /home/tomsw/amust_files/env_nanosim
vcs +define+DUT=teak__spaHarvard_V5T +define+TECHFILE='"'${EXAMPLE_CELLS}'"' \
	+define+TEAK \
	+define+NO_ACTIVATE \
	+define+NLSTFILE='"teak.v"' +define+RESET \
	+define+PROGFILE='"../tests/hello.hex"' \
	+define+DUMPFILE='"/tmp/a.vcd"' +define+DUMPVARS=1 test-spaHarvardT.v \
	${RUNTIME}/monitors.v \
	${RUNTIME}/runtime.v
	+v2k
./simv
