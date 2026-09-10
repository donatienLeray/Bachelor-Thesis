# [PATHS]
# Auto-detected from this script's own location so nothing here needs to be
# personalized: EXPERIMENTFOLDER is this script's directory (BachelorProjekt/),
# and MAINFOLDER is its parent (the repo root), matching the argos-python/
# toychain submodule paths declared in .gitmodules. Must be sourced (or run)
# with BachelorProjekt/ as the working directory, as documented in the README.
export HOMEFOLDER="$HOME"
export EXPERIMENTFOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MAINFOLDER="$(dirname "$EXPERIMENTFOLDER")"
export ARGOSFOLDER="$MAINFOLDER/argos-python"
export TOYCHFOLDER="$MAINFOLDER/toychain"
# [[ ":$PATH:" != *":$MAINFOLDER/scripts:"* ]] && export PATH=$PATH:$MAINFOLDER/scripts

# [SC]
# Which consensus protocol the robots run. One of:
#   ProofOfAuthority  -> PoA  (fixed round-robin block producer rotation)
#   ProofOfWork       -> PoW  (classic proof-of-work mining)
#   ProofOfConnection -> C-PoA or R-PoA (see below) -- ranks/picks the next
#                         block producer by recent network connectivity
#                         (C-PoA) or at random (R-PoA)
#   ProofOfStake      -> PoS  (not used/evaluated in the thesis)
# C-PoA vs. R-PoA are BOTH "ProofOfConnection" here; which one you actually
# get is controlled by params['scs']['update'] in loop_functions/params.py
# (see run-experiment.sh's `loopconfig "scs" "update" ...` calls):
#   "peer_index" -> connectivity-ranked producer selection = C-PoA
#   "no_update"  -> random producer selection               = R-PoA
export CONSENSUS=ProofOfConnection
case "$CONSENSUS" in
	"ProofOfAuthority")  export SCNAME="poa_w" ;;
	"ProofOfConnection") export SCNAME="poc" ;;
	"ProofOfWork")       export SCNAME="poa_w" ;;
	"ProofOfStake")      export SCNAME="pos" ;;
	*)                    #errormessage
		echo "Unknown consensus mechanism: $CONSENSUS"
		exit 1
		;;
esac
export SCFILE="${EXPERIMENTFOLDER}/scs/${SCNAME}.py" 
export GENESISFILE="${DOCKERFOLDER}/geth/files/$GENESISNAME.json"


# [ARGOS]
# Which ARGoS scenario/world to load, matching the thesis's S1-S4 scenarios
# (see Section 3.2.1). CTRL must be set consistently with ARGOSNAME:
#   ARGOSNAME=greeter  + CTRL=main.py          -> S1 (well-mixed random walk)
#                                                  or S2 (heterogeneous speed,
#                                                  toggle with SPEEDUNIFORM below)
#   ARGOSNAME=obstacle + CTRL=main.py          -> S3 (random walk, obstacle trap)
#   ARGOSNAME=foraging + CTRL=main_foraging.py -> S4 (foraging)
export ARGOSNAME=foraging
export ARGOSFILE="${EXPERIMENTFOLDER}/experiments/${ARGOSNAME}.argos"
export ARGOSTEMPLATE="${EXPERIMENTFOLDER}/experiments/${ARGOSNAME}.x.argos"
export CTRL=main_foraging.py
export CON1="${EXPERIMENTFOLDER}/controllers/${CTRL}"


export RABRANGE="0.5"
export WHEELNOISE="0"
# Simulated ticks per simulated second. Also the unit-to-seconds conversion
# factor for tick-based values elsewhere in the codebase (e.g. block period,
# C-PoA's peer-connection decay window in loop_functions/params.py).
export TPS=10
export DENSITY="2"
# Robot speed (cm/s). Only used directly when SPEEDUNIFORM=True below.
export AGENTSPEED=18
# True = all robots move at AGENTSPEED (S1/S3/S4).
# False = seeded symmetric pairs around AGENTSPEED, e.g. mean 18 with 5 robots
# could give [15, 21, 13, 23, 18] (S2, heterogeneous-speed scenario).
export SPEEDUNIFORM=True


# Swarm size |N| -- the thesis sweeps this over {5, 10, 15, 20, 25}.
export NUMROBOTS=5

# Everything below this point (arena/obstacle/patch geometry) is auto-derived
# from NUMROBOTS, DENSITY, and ARGOSNAME -- no need to edit these by hand.

# obstacle dimensions
export SCALINGF=$(echo "scale=3 ; sqrt($NUMROBOTS/5)" | bc)
export OBSTACLEB=$(echo "scale=3 ; 0.5*$SCALINGF" | bc)

# Arena dimension (obstacle arna needs to factor out the obstacle size, forage )
case "$ARGOSNAME" in
	"obstacle") export ARENADIM=$(echo "scale=3 ; 2.469*$SCALINGF" | bc) ;;
	*)          export ARENADIM=$(echo "scale=3 ; sqrt($NUMROBOTS/$DENSITY)" | bc) ;;
esac

export ARENADIMH=$(echo "scale=3 ; $ARENADIM/2" | bc)
export STARTDIM=$(echo "scale=3 ; $ARENADIM/5" | bc)

# obstacle dimensions

export OBSTACLEL=$(echo "scale=3 ; 0.836*$SCALINGF" | bc)
export OBSTACLEOFFSET=$(echo "scale=3 ; $ARENADIMH-$OBSTACLEL/2" | bc)
export POINTDIM=$(echo "scale=3 ; $OBSTACLEB/sqrt(2)" | bc)
export POINTOFFSET=$(echo "scale=3 ; $ARENADIMH-$OBSTACLEL+$OBSTACLEB/2" | bc)
export POINTH=$(echo "scale=3 ; $OBSTACLEB/2" | bc)

# Top-right square side length in meters for entry/exit logging.
export ZONE_SIZE=$(echo "scale=3 ; $OBSTACLEL+$OBSTACLEB" | bc)

# Start 1/5 of the robots inside the triangle in a smaller square fully contained in it.
export TRIANGLE_ROBOTS=$(echo "scale=0 ; $NUMROBOTS/5" | bc)
export OUTSIDE_TRIANGLE_ROBOTS=$(echo "$NUMROBOTS-$TRIANGLE_ROBOTS" | bc)
export TRIANGLE_START_SIZE=$(echo "scale=3 ; $ZONE_SIZE/2" | bc)
export TRIANGLE_START_MIN=$(echo "scale=3 ; $ARENADIMH-$TRIANGLE_START_SIZE" | bc)

# Foraging specific parameters
export PATCHES_COUNT=$(echo "scale=0 ; $ARENADIM*15" | bc)
# export PATCHES_COUNT_B=$(echo "scale=0 ; $ARENADIM*25" | bc)


# [TOYCHAIN]
# NOTE: currently has no effect -- each protocol's actual block period is a
# fixed BLOCK_PERIOD=10 ticks (1s at TPS=10) hardcoded in its own module under
# toychain/src/consensus/. Changing this value won't change block timing.
export BLOCKPERIOD=2
# Live blockchain explorer web UI (http://EXPLORER_HOST:EXPLORER_PORT) while a
# run is going. Leave False for normal/batch runs.
export EXPLORER=False
export EXPLORER_PATH="$TOYCHFOLDER/src/plugins/toychain-explorer/"
export EXPLORER_HOST="localhost"
export EXPLORER_PORT="8765"

# [OTHER]
export SEED=420
# When True (default), each repetition's SEED is overridden with REP*42 (see
# run-experiment.sh's `run()`), so repetitions are reproducible but distinct.
export REP_SEED=True
# Real-world wall-clock safety timeout for one run, in MINUTES.
export TIMELIMIT=100
# Simulated experiment duration, in SECONDS of simulated time (ARGoS
# <experiment length="LENGTH" ticks_per_second="TPS"/>). Total control steps
# per run = LENGTH * TPS.
export LENGTH=400
export SLEEPTIME=5
# Number of repetitions per configuration (the thesis uses 30).
export REPS=30
export NOTES="just a test"




