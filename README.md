# Adaptive Blockchain Consensus for Dynamic Robot Swarm Networks

This repository contains the full simulation environment, experiment code, and final report for my [bachelor thesis](./Bachelor_Thesis.pdf) on connectivity-aware blockchain consensus for mobile robot swarms. (2026)


## Table of Contents

- [Overview](#overview)
- [Repository structure](#repository-structure)
- [Setup](#setup)
  - [Minimal setup (view data & plots only)](#minimal-setup-view-data--plots-only)
  - [Full setup (run simulations & experiments)](#full-setup-run-simulations--experiments)
- [Running Simulation](#running-simulation)
- [Running experiments](#running-experiments)
- [Generating the plots](#generating-the-plots)
- [References](#references)
- [Acknowledgments](#acknowledgments)

## Overview

Blockchain consensus protocols are designed for stable, well-connected computer networks, but robot swarms communicate over sparse, dynamic, and frequently partitioned wireless links. Applied unmodified, this mismatch causes wasted computation, weakened safety, and slow information exchange.

This thesis introduces:

> **Connectivity-aware Proof-of-Authority (C-PoA)**

a Proof-of-Authority (PoA) extension that ranks block producers by their recent network connectivity instead of a fixed round-robin, so that robots best positioned to create and propagate a useful block do so — reducing fork formation and speeding up information exchange in fragmented swarm topologies.

A second protocol, **Randomized PoA (R-PoA)**, is introduced purely as a control: it replaces PoA's fixed rotation with a random one, letting the thesis isolate whether any gain from C-PoA is actually due to connectivity-aware selection, rather than to randomization alone.

## Repository structure

```
.
├── argos-python/             # ARGoS <-> Python controller bridge (submodule)
├── toychain/                 # Toychain blockchain, incl. consensus protocol implementations (submodule)
│   └── src/consensus/        # ProofOfWork (PoW), ProofOfAuthority (PoA), ProofOfConnection (C-PoA/R-PoA),ProoOfStake (PoS) 
├── BachelorProjekt/
│   ├── controllers/           # Robot controllers (main.py / main_foraging.py) + sensor/actuator helpers
│   ├── MarketForaging/        # Foraging-scenario sensors/actuators used by main_foraging.py (vendored from donatienLeray/toychain-argos)
│   ├── loop_functions/        # ARGoS loop functions and experiment parameters (params.py)
│   ├── scs/                   # Smart-contract-style consensus logic per protocol
│   ├── experiments/           # ARGoS scenario templates (*.x.argos); concrete *.argos are generated, not committed
│   ├── experimentconfig.sh    # Experiment parameters (consensus, swarm size, repetitions, ...)
│   ├── run-experiment.sh      # Entry point: runs repetitions across configs
│   ├── starter.sh             # Launches a single ARGoS run
│   └── results/
│       ├── data/               # Raw per-run CSV/JSON logs, one folder per scenario (S1–S4)
│       ├── plots/              # plots generated in plots.ipyng are saved here
│       ├── plothelpers.py      # Shared helpers: loading raw logs, computing metrics, styling
│       └── plots.ipynb         # Notebook that produces every plot in the thesis and more
├── Bachelor_Thesis.pdf         
└── README.md
```

## Setup

This repository serves two different purposes, and you only need to set up for the one you actually want:

- **Just want to look at the results and regenerate the thesis figures?** → [Minimal setup](#minimal-setup-view-data--plots-only). It's pure Python, works on any OS, and doesn't touch ARGoS at all.
- **Want to run new simulations/experiments yourself?** → [Full setup](#full-setup-run-simulations--experiments). This additionally requires **ARGoS**, which only builds and runs on **Ubuntu 20.04 or 22.04** — everything else in this section exists to support that.

### Minimal setup (view data & plots only)

1. Clone the repository — submodules aren't needed for this path, since the plotting code never touches `toychain`/`argos-python`:

   ```
   git clone https://github.com/donatienLeray/Bachelor-Thesis.git
   cd Bachelor-Thesis
   ```

2. That's it for setup — jump to [Generating the plots](#generating-the-plots) for the (one) `pip install` and how to open the notebook. It reads the CSV/JSON logs already committed under [`BachelorProjekt/results/data/`](./BachelorProjekt/results/data/).

### Full setup (run simulations & experiments)

> ⚠️ Requires **Ubuntu 20.04 or 22.04** specifically — ARGoS (and the e-puck plugin below) only build and run on these.

#### 1. Clone the repository

```
git clone --recurse-submodules https://github.com/donatienLeray/Bachelor-Thesis.git
cd Bachelor-Thesis
```

If you already cloned without submodules:

```
git submodule update --init --recursive
```

#### 2. Install ARGoS

```
sudo apt install git build-essential cmake g++ libfreeimage-dev libfreeimageplus-dev freeglut3-dev \
libxi-dev libxmu-dev liblua5.3-dev lua5.3 doxygen graphviz graphviz-dev asciidoc
```

Ubuntu 20.04:
```
sudo apt install qt5-default
```
Ubuntu 22.04:
```
sudo apt install qtbase5-dev qt5-qmake
```

Then build and install ARGoS ([ilpincy/argos3](https://github.com/ilpincy/argos3)):
```
git clone https://github.com/ilpincy/argos3.git
cd argos3/ && mkdir build && cd build
cmake ../src && make -j4 && make doc
sudo make install && sudo ldconfig
```

#### 3. Install the e-puck plugin

```
git clone https://github.com/demiurge-project/argos3-epuck.git
cd argos3-epuck/ && mkdir build && cd build
cmake ../src && make
sudo make install && sudo ldconfig
```

#### 4. Build the ARGoS–Python bridge and install Python deps

```
sudo apt-get install g++ cmake git libboost-python-dev
cd argos-python
git fetch && git checkout temp
mkdir build && cd build
cmake .. && make
```
```
sudo apt install python3-pip
pip install aenum psutil
```

With this done, continue to [Running Simulation](#running-simulation). You'll still want the [Minimal setup](#minimal-setup-view-data--plots-only)'s `pip install` afterward to turn your new logs into plots.

## Running Simulation

For a single, one-off simulation — e.g. to visualize a scenario or sanity-check a change — set the parameters directly in [`experimentconfig.sh`](./BachelorProjekt/experimentconfig.sh) and launch it yourself. All paths in that file are auto-detected from the repo's own location, so nothing there needs to be personalized; only the parameters below are meant to be edited. Every variable is also commented in the file itself.

The parameters you'll actually want to change:

| Variable | Controls |
|---|---|
| `CONSENSUS` | Protocol: `ProofOfAuthority` (PoA), `ProofOfWork` (PoW), `ProofOfConnection` (C-PoA *or* R-PoA — see below), `ProofOfStake` (unused in the thesis) |
| `ARGOSNAME` + `CTRL` | Scenario: `greeter`+`main.py` = S1/S2, `obstacle`+`main.py` = S3, `foraging`+`main_foraging.py` = S4 |
| `NUMROBOTS` | Swarm size `\|N\|` (thesis sweeps `{5, 10, 15, 20, 25}`) |
| `DENSITY` | Density of agents in arena (unchanged in the thesis). Size and from of the arena is automatically derived from `NUMROBOTS`, `DENSITY`, and `ARGOSNAME`|
| `SPEEDUNIFORM` | `True` = all robots same speed; `False` = symmetric random pairs around `AGENTSPEED` (used for S2) |
| `RABRANGE` | Communication range of the agents (unchanged in the thesis)|
| `WHEELNOISE` | (0 in the thesis)|
| `LENGTH` / `TPS` | Simulated run duration in seconds / ticks-per-second (`LENGTH * TPS` = total control steps) |
| `REPS` / `REP_SEED` | Repetitions per config, and whether each gets its own seed |
| `EXPLORER` | Live blockchain explorer web UI (http://`EXPLORER_HOST`:`EXPLORER_PORT`) while a run is going.|

C-PoA vs. R-PoA are **both** `CONSENSUS=ProofOfConnection`; which one you get depends on `params['scs']['update']` in `loop_functions/params.py` (`"peer_index"` = connectivity-ranked = C-PoA, `"no_update"` = random = R-PoA) — see the comment above `CONSENSUS` in [`experimentconfig.sh`](./BachelorProjekt/experimentconfig.sh) for details.

Once configured, launch a run from `BachelorProjekt/`:

```
cd BachelorProjekt
bash starter.sh -r -s
```

- `-s` / `--start`: run with the ARGoS GUI
- `-sz` / `--start-novis`: run headless (faster, no visualization)
- `-l` / `--logs`: also open a `tmux` pane tailing every robot's `monitor.log`
- `-p` / `--python`: also open a `tmux` pane with a Python console per robot

This regenerates the ARGoS world file from the scenario template, deploys the selected protocol's smart contract, and starts exactly one run with whatever [`experimentconfig.sh`](./BachelorProjekt/experimentconfig.sh) currently has set — no repetitions, no data collection, just one simulation to look at.

## Running experiments

To reproduce the thesis's full result set, [`run-experiment.sh`](./BachelorProjekt/run-experiment.sh) automates what "Running Simulation" does manually: for each of the 4 scenarios, it configures every consensus protocol across all 5 swarm sizes and runs `REPS` repetitions of each, writing the results to [`BachelorProjekt/results/data/`](./BachelorProjekt/results/data/). All paths are auto-detected, as above — no path setup needed here either.

Each scenario block in the script follows the same pattern:
1. Set the scenario (`ARGOSNAME`, `CTRL`, `SPEEDUNIFORM`) via `config "VAR" value`, which edits [`experimentconfig.sh`](./BachelorProjekt/experimentconfig.sh) in place.
2. Set R-PoA's parameters (`CONSENSUS=ProofOfConnection`, `scs.update=no_update`) via `loopconfig "dict" "key" value`, which edits `loop_functions/params.py` in place, then loop over swarm sizes calling `run "experimentName/configName"`.
3. Repeat for PoA, PoW, and C-PoA (`scs.update=peer_index`) together, looping over both consensus and swarm size.

**To run everything** (takes a very long time — 4 scenarios × 4 protocols × 5 swarm sizes × 30 repetitions):

```
cd BachelorProjekt
./run-experiment.sh -r -s      # add -sz instead of -s to run headless/faster
```

**To run a subset**, edit `run-experiment.sh` directly: comment out whichever `EXP=...` scenario blocks you don't need, or narrow the `for UTIL in $(seq 5 5 25)` swarm-size range / `for consensus in ...` protocol list inside a block. The commented-out `TESTS` block near the top of the file is a template for a single ad-hoc configuration if you'd rather not touch the main blocks at all.

The helper functions used throughout the script can also be called manually (after `source ./experimentconfig.sh` or `source ./run-experiment.sh`):
- `config "VAR" value` — set one variable in `experimentconfig.sh`
- `loopconfig "dict" "key" value` — set one `params['dict']['key']` entry in `loop_functions/params.py` (this is how C-PoA/R-PoA and the peer-connection decay window are controlled, since they live outside `experimentconfig.sh`)
- `run "experimentName/configName" [-t]` — run `REPS` repetitions of the currently configured settings, writing to `results/data/experiment_<experimentName>/<configName>/`; pass `-t` to run once with no data collection, as a quick smoke test

Each repetition writes the full blockchain and communication log of every robot to CSV under `results/data/experiment_<N>_<name>/<consensus>_<numagents>/<rep>/`, which is what the plotting pipeline below consumes.


## Generating the plots

All figures in the thesis are produced from these raw per-run [CSV logs](./Bachelor-Thesis/tree/main/BachelorProjekt/results/data) via [`plots.ipymn`](./BachelorProjekt/results/plots.ipynb),which, together with the helper module [`plothelpers.py`](./BachelorProjekt/results/plothelpers.py) in the same folder, loads the raw logs, reconstructs the canonical chain per run, computes the metrics from Section 3.3 of the thesis (AE, BI, BPD, Degree of Decentralization, Safety, and the scenario-specific TRT/ICF), and renders every figure exactly as it appears in the thesis.

This needs its own set of Python packages, separate from the experiment-running deps above:

```
pip install pandas numpy matplotlib ipywidgets jupyter
```
How exactly to load the data and generate the plots is explanied directly in [`plots.ipymn`](./BachelorProjekt/results/plots.ipynb).

```
cd BachelorProjekt/results
jupyter notebook plots.ipynb
```

Autosaved plots, all plots used in the  [`Bachelor_Thesis.pdf`](./Bachelor_Thesis.pdf) as well as some supplementary ones can be found in [`BachelorProjekt/results/plots/`](./BachelorProjekt/results/plots/).


## References

This project builds on:

- [Toychain](https://github.com/donatienLeray/toychain) — lightweight blockchain implementation with pluggable consensus protocols
- [Toychain-ARGoS](https://github.com/teksander/toychain-argos) / [argos-python](https://github.com/KenN7/argos-python) — Toychain–ARGoS integration
- [ARGoS](https://www.argos-sim.info/) — multi-robot simulator
- Full bibliography in [`Bachelor_Thesis.pdf`](./Bachelor_Thesis.pdf)

## Acknowledgments

I would like to thank:

- **[Alexandre Melo Pacheco](https://www.researchgate.net/profile/Alexandre-Pacheco-7)**: the main source of knowledge behind this thesis, whose work and ideas inspired it from the start, and who provided remote supervision, support, and helpful discussions throughout
- **[Andreagiovanni Reina](https://www.giovannireina.com/index.php)** for supervising this thesis and providing valuable guidance
- **[Michael Grossniklaus](https://www.uni-konstanz.de/centre-for-human-data-society/people/prof-dr-michael-grossniklaus/)** for evaluating this thesis