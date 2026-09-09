# Adaptive Blockchain Consensus for Dynamic Robot Swarm Networks

This repository contains the full simulation environment, experiment code, and final report for my bachelor thesis on connectivity-aware blockchain consensus for mobile robot swarms. (2026)

📎 Companion repo: [Bachelor-Project](https://github.com/donatienLeray/Bachelor-Project) — the earlier project-stage write-up, presentation, and the result data/plots this thesis builds on.

---

## 📖 Overview

[#-overview](#-overview)

Blockchain consensus protocols are designed for stable, well-connected computer networks, but robot swarms communicate over sparse, dynamic, and frequently partitioned wireless links. Applied unmodified, this mismatch causes wasted computation, weakened safety, and slow information exchange.

This thesis introduces:

> **Connectivity-aware Proof-of-Authority (C-PoA)**

a Proof-of-Authority (PoA) extension that ranks block producers by their recent network connectivity instead of a fixed round-robin, so that robots best positioned to create and propagate a useful block do so — reducing fork formation and speeding up information exchange in fragmented swarm topologies.

A second protocol, **Randomized PoA (R-PoA)**, is introduced purely as a control: it replaces PoA's fixed rotation with a random one, letting the thesis isolate whether any gain from C-PoA is actually due to connectivity-aware selection, rather than to randomization alone.

---

## 🚀 Key Contributions

[#-key-contributions](#-key-contributions)

- Design and implementation of **C-PoA**, a connectivity-aware block producer ranking for PoA
- **R-PoA**, a randomized control protocol isolating the effect of connectivity-aware selection
- Simulation-based benchmark of **C-PoA vs. PoA vs. PoW vs. R-PoA** in [Toychain-ARGoS](https://github.com/teksander/toychain-argos), across four swarm scenarios (well-mixed, heterogeneous-speed, obstacle-trapped, and foraging) and five swarm sizes (`|N| ∈ {5, 10, 15, 20, 25}`)
- A metrics suite covering Agreement Efficiency, Block Interval, Block Propagation Delay, Degree of Decentralization, and Safety (normalized Nakamoto coefficient)

---

## 📊 Results Summary

[#-results-summary](#-results-summary)

- **C-PoA improves consensus speed** (agreement efficiency and block propagation) over PoA, without weakening resistance to a colluding minority of nodes
- The improvement is **attributable to connectivity-based selection specifically**, not to randomization alone — confirmed by comparison against R-PoA
- The gain **does not escape blockchain's characteristic negative scaling** with swarm size; further work is needed on the underlying mechanism before real-world deployment

Full results, figures, and discussion: [`Bachelor_Thesis.pdf`](./Bachelor_Thesis.pdf) (Section 4).

---

## ⚙️ Setup

[#️-setup](#️-setup)

### 1. Clone the repository

```
git clone --recurse-submodules https://github.com/donatienLeray/Bachelor-Thesis.git
cd Bachelor-Thesis
```

If you already cloned without submodules:

```
git submodule update --init --recursive
```

### 2. Install ARGoS

Assumes a clean install of Ubuntu 20.04 or 22.04.

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

### 3. Install the e-puck plugin

```
git clone https://github.com/demiurge-project/argos3-epuck.git
cd argos3-epuck/ && mkdir build && cd build
cmake ../src && make
sudo make install && sudo ldconfig
```

### 4. Build the ARGoS–Python bridge and install Python deps

```
sudo apt-get install g++ cmake git libboost-python-dev
cd argos-python
git fetch && git checkout temp
mkdir build && cd build
cmake .. && make
```
```
sudo apt install python3-pip
pip install aenum psutil hexbytes
```

---

## 🧪 Running experiments

Each run simulates `N` e-puck2 robots executing one of the four consensus protocols (PoW, PoA, C-PoA, R-PoA) under one of four test scenarios (`S1`–`S4`, see thesis Section 3.2.1). All paths in `experimentconfig.sh` are auto-detected from the repo's own location — no path setup needed. Edit it only to change experiment parameters (consensus, swarm size, repetitions, etc.), then:

```
cd BachelorProjekt
./run-experiment.sh -r -s
```

Each run writes the full blockchain and communication log of every robot to CSV, which is what the plotting pipeline below consumes.

---

## 📈 Generating the plots

All figures in the thesis are produced from these raw per-run CSV logs via:

```
BachelorProjekt/results/plots.ipynb
```

which, together with the helper module `plothelpers.py` in the same folder, loads the raw logs, reconstructs the canonical chain per run, computes the metrics from Section 3.3 of the thesis (AE, BI, BPD, Degree of Decentralization, Safety, and the scenario-specific TRT/ICF), and renders every figure exactly as it appears in the thesis.

```
cd BachelorProjekt/results
jupyter notebook plots.ipynb
```

No path setup is needed here either — `plothelpers.py` resolves everything relative to the notebook's own folder or to the current user's home directory.

For the underlying result data and additional, more detailed plot variants, see [Bachelor-Project](https://github.com/donatienLeray/Bachelor-Project).

---

## 📄 Thesis

[#-thesis](#-thesis)

- 📘 **Full thesis**: [`Bachelor_Thesis.pdf`](./Bachelor_Thesis.pdf)
- Donatien A. Leray — Department of Computer and Information Science, University of Konstanz, 2026
- Evaluated by Dr. Andreagiovanni Reina and Prof. Dr. Michael Grossniklaus · Remote supervision by Dr. Alexandre Pacheco

---

## 🔮 Future Work

[#-future-work](#-future-work)

- Redesign Scenario 2/3 to isolate speed- vs. topology-driven connectivity advantages and reduce run-to-run variance
- Increase repetitions per configuration and extend swarm size well beyond `|N| = 25`, where several trends (e.g. PoW's decentralization) have not yet plateaued
- Systematically vary the fixed parameters (Table 2) to test which results generalize
- Explore an adaptive block period tied to swarm connectivity
- Investigate the mechanism behind C-PoA's negative scaling before real-world deployment

---

## 📚 References

[#-references](#-references)

This project builds on:

- [Toychain](https://github.com/donatienLeray/toychain) — lightweight blockchain implementation with pluggable consensus protocols
- [Toychain-ARGoS](https://github.com/teksander/toychain-argos) / [argos-python](https://github.com/KenN7/argos-python) — Toychain–ARGoS integration
- [ARGoS](https://www.argos-sim.info/) — multi-robot simulator
- Full bibliography in `Bachelor_Thesis.pdf`

---

## 🙏 Acknowledgments

[#-acknowledgments](#-acknowledgments)

I would like to thank:

- **[Andreagiovanni Reina](https://www.giovannireina.com/index.php)** for supervising this thesis and providing valuable guidance
- **Michael Grossniklaus** for evaluating this thesis
- **[Alexandre Melo Pacheco](https://www.researchgate.net/profile/Alexandre-Pacheco-7)** for remote supervision, support, and helpful discussions 