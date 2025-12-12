# Coupling-Nut-Joint-Safety-Analysis
A MATLAB-based structural analysis and optimisation tool for evaluating coupling-nut joints used in semi-cryogenic engine fluid pipelines. The project focuses on preload–torque modelling, stress evaluation, factor-of-safety estimation, and geometry optimisation, supported by an interactive App Designer GUI.

## Overview
This project develops a computational tool to analyse the structural behaviour of coupling-nut joints (in 11 seperate configurations) used for connecting cryogenic propellant transfer lines (e.g., LOX/LH₂) in test facilities.

The tool implements analytical formulations to calculate:

Preload force and tightening torque

Stress margins for interface elements and resulting factors of safety

An integrated optimisation module explores feasible nut geometries that satisfy user-specified limits. The project also includes a complete MATLAB App Designer GUI for engineers to perform parametric studies, visualise stresses, and export results.

## Tools Used

MATLAB (analytical modelling, geometry optimisation)

MATLAB App Designer (GUI development)

Engineering Handbooks (validation & reference)

## Extended Description

The App Designer interface (CouplingNutApp4.mlapp) integrates all major calculation functions internally. However, two external functions must be present on the same MATLAB path for full tool operation:

run_solver.m – executes the complete preload, stress, and FoS evaluation pipeline

extract_min_fos.m – computes the governing (minimum) factor of safety across all evaluated components

All remaining helper functions are embedded within the App Designer code, so no additional setup is required when launching the GUI.

For users who prefer working directly with scripts, the project also includes coupling_nut_tool.m, which runs the full analysis line-by-line in the MATLAB environment. To use the script version, ensure that all external functions (run_solver.m, extract_min_fos.m, load_config_rules.m and any additional computation scripts) are located in the same MATLAB directory or added to the MATLAB path.
