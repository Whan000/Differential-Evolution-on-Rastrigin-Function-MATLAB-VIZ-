# Differential Evolution on the Rastrigin Function (MATLAB)

![status](https://img.shields.io/badge/Status-active-brightgreen.svg)
![matlab](https://img.shields.io/badge/MATLAB-R2024b%2B-orange.svg)
![algorithm](https://img.shields.io/badge/Algorithm-Differential%20Evolution-blue.svg)
![visualization](https://img.shields.io/badge/Visualization-4--panel-success.svg)

This repository provides a **fully visualized implementation** of the **Differential Evolution (DE)** algorithm on the **Rastrigin benchmark function** in MATLAB. It is written to be readable, modifiable, and suitable for demonstrations in classes, lab sessions, and research introductions to evolutionary computation.

📺 **Demo / explanation video**  
https://www.youtube.com/watch?v=sL2Ta3qHX3U

---

## Table of Contents

1. [Overview](#overview)  
2. [Key Features](#key-features)  
3. [Prerequisites](#prerequisites)  
4. [How to Run](#how-to-run)  
5. [File Structure](#file-structure)  
6. [Parameter Guide](#parameter-guide)  
    - [Core Parameters](#core-parameters)
    - [Effect of Parameters](#effect-of-parameters)
7. [What the Script Does](#what-the-script-does)  
8. [Visualization Layout](#visualization-layout)  
9. [Changing the Objective Function](#changing-the-objective-function)  
10. [Typical Output](#typical-output)  
11. [FAQ](#faq)  
12. [References](#references)  
13. [Citation](#citation)  
14. [License](#license)

---

## Overview

The script implements the classic **DE/rand/1/bin** variant of Differential Evolution to minimize the **Rastrigin** function. The Rastrigin function is intentionally chosen because:

- it is **multimodal** (many local minima),
- it is **bounded** (commonly \[-5.12, 5.12\]),
- and it is **standard in optimization literature**, which makes it easy to compare.

To make the optimization process *visible*, the script displays **four synchronized plots**:

1. a 3D surface of the Rastrigin function,
2. a 2D contour (top view) with population movement,
3. a convergence curve,
4. a parameter/status panel (live refreshed).

This makes it ideal for teaching **population-based search**, showing **exploration → exploitation**, and demonstrating **early stopping**.

---

## Key Features

- ✅ Pure MATLAB, single-file script
- ✅ Differential Evolution (mutation, crossover, selection)
- ✅ Early stopping based on **fitnessThreshold**
- ✅ **4-panel live visualization** using `tiledlayout`
- ✅ Population dots update every generation
- ✅ Text-based status showing best solution so far
- ✅ Designed for **D = 2** problems so that visualization is meaningful
- ✅ Easy to extend to other benchmark functions

---

## Prerequisites

- **MATLAB**: R2018b or later is recommended (earlier versions may still work if they support `tiledlayout`)
- No additional toolboxes required
- A machine capable of redrawing ~1000 points per iteration

---

## How to Run

1. **Clone or download** this repository.
2. Save the MATLAB script (for example as `de_rastrigin.m`).
3. Open the script in MATLAB.
4. Run:

   ```matlab
   de_rastrigin


or simply press **Run** in the MATLAB editor.

5. A figure window will open with 4 subplots that update every generation.

> **Note:** if the animation is too slow, reduce `NP`, reduce `GenMax`, or decrease `pause(0.05)` in the main loop.

---

## File Structure

```text
.
├── README.md          ← this file
└── de_rastrigin.m     ← main MATLAB script (the code you provided)
```

You can rename the script to anything (e.g. `main.m`, `demo_de.m`), but keep the Rastrigin function in the same file or on the MATLAB path.

---

## Parameter Guide

All parameters are declared at the top of the script:

```matlab
D = 2;                        % Problem dimension
NP = 1000;                    % Population size
F = 0.8;                      % Mutation factor
CR = 0.9;                     % Crossover rate
GenMax = 1000;                % Maximum generations
bounds = [-5.12, 5.12];       % Variable bounds
fitnessThreshold = 0.000001;  % Stop if best fitness < this value
```

### Core Parameters

| Parameter          | Description                                                       | Typical Values / Notes                                                     |
| ------------------ | ----------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `D`                | Number of dimensions of the optimization problem                  | `2` for visualization. You can set `3+`, but only first 2 dims are plotted |
| `NP`               | Population size (number of candidate solutions)                   | 10–100×D. Here `1000` is large to make movement visible                    |
| `F`                | Mutation factor (also called differential weight)                 | `0.4 – 1.0`. Higher → larger jumps                                         |
| `CR`               | Crossover rate (probability to inherit from mutant)               | `0.7 – 1.0` is common                                                      |
| `GenMax`           | Maximum number of generations to run                              | Acts as a hard stop                                                        |
| `bounds`           | Lower and upper bounds for every variable                         | For Rastrigin, `[-5.12, 5.12]` is standard                                 |
| `fitnessThreshold` | If best fitness drops below this value, the algorithm stops early | Use `1e-6` or `1e-8` depending on precision requirement                    |

### Effect of Parameters

* **Increase `NP`** → better coverage, more accurate solution, but slower.
* **Increase `F`** → more exploration but may overshoot.
* **Decrease `CR`** → offspring resemble parent more (more exploitation).
* **Tighten `fitnessThreshold`** → algorithm tries longer to get closer to global minimum.
* **Increase `GenMax`** → allows more evolution, but may not be needed if early stopping works.

---

## What the Script Does

The main loop:

1. **For each individual `i`** in the population:

   * Randomly pick **3 distinct** individuals: `x1`, `x2`, `x3`
   * **Mutation:**
     [
     v = x_1 + F \cdot (x_2 - x_3)
     ]
     Then clip `v` to bounds.
   * **Binomial crossover:** create trial vector `u` by mixing current individual and mutant vector.
   * **Selection:** if `f(u) <= f(x_i)` then `u` replaces `x_i`.
2. **After each generation**:

   * find best fitness & best solution
   * update all 4 plots
   * save best fitness to `fitnessHistory(gen)`
   * check **early stopping**:

     ```matlab
     if bestVal < fitnessThreshold
         break;
     end
     ```
3. **At the end**: print best solution and reason for stopping.

This flow is consistent with the **canonical DE algorithm** as proposed by Storn and Price (1997) and later described in standard evolutionary computation textbooks.

---

## Visualization Layout

The script uses:

```matlab
figure('Position',[100 100 1600 800]);
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');
```

and then:

1. **Plot 1 (top-left):** 3D surface of Rastrigin

   * `surf(...)`
   * population plotted with `plot3(...)`
   * best individual in **red**
2. **Plot 2 (top-right):** 2D contour, square aspect

   * `contourf(...)`
   * enforced:

     ```matlab
     axis(ax2, 'equal');
     axis(ax2, 'square');
     ```
   * shows population spreading and clustering
3. **Plot 3 (bottom-left):** convergence curve

   * x-axis: generation
   * y-axis: best fitness
4. **Plot 4 (bottom-right):** parameter & status panel

   * shown using `text(...)`
   * displays current generation, best fitness, best solution, convergence status

This setup is especially useful for **screen recording**, **YouTube tutorials**, and **live lectures**, where students can *see* the optimization progress.

---

## Changing the Objective Function

The Rastrigin function is defined at the end:

```matlab
function f = rastrigin(X)
    A = 10;
    f = A * size(X, 2) + sum(X.^2 - A * cos(2 * pi * X), 2);
end
```

To optimize **your own** function:

1. Define a new function, e.g.:

   ```matlab
   function f = myfun(X)
       % X is N x D
       f = sum(X.^2, 2);  % example: sphere
   end
   ```

2. Replace **every** call to `rastrigin(...)` with `myfun(...)`:

   ```matlab
   fitness = myfun(pop);
   ...
   zgrid = myfun([xgrid(:), ygrid(:)]);
   ```

3. Adjust `bounds` to your function domain.

> **Important:** the script assumes that the function can evaluate **many points at once** (vectorized call). Keep that behavior for speed.

---

## Typical Output

You will see prints like:

```text
Generation 1: Best Fitness = 43.219381
Generation 10: Best Fitness = 12.004826
Generation 20: Best Fitness = 0.948201
*** CONVERGENCE ACHIEVED ***
Generation 37: Best Fitness = 0.000001 (below threshold 0.000001)
----------------------------------------
STOPPED: Fitness threshold reached at generation 37
Best Solution Found: [0.0000, -0.0000]
Function Value: 0.000001
```

* If you **do not** reach the threshold, it will say:

  ```text
  COMPLETED: Maximum generations reached
  ```

* The figure will stop updating after exit.

---

## FAQ

**Q1. Can I increase the dimension `D` to 10 or 30?**
Yes. DE will still work. However, only the **first two dimensions** are visualized in plots 1 and 2 because we cannot draw high-dimensional spaces nicely. For higher dimensions, rely on the **convergence curve** and console output.

**Q2. MATLAB is slow with `NP = 1000`. What should I do?**
Reduce:

* `NP` to 200–300
* or `GenMax`
* or remove / slow down plotting (`drawnow` → comment it)
  This repo is intentionally **visual-first**, so performance can be traded for clarity.

**Q3. Can I use another benchmark (Sphere, Ackley, Rosenbrock)?**
Yes. Just replace the objective function and adjust `bounds`. Keep the vectorized input-output format.

**Q4. Why Rastrigin?**
Because it has many local minima and a known global minimum at **x = 0** with **f(0) = 0**, which makes it very convenient to check whether DE is working.


## Citation

If you use this repository in a course report, assignment, or academic demo, you may cite it as:

> **Phuriwat Kasamesookphaisal** (2025). *Differential Evolution on the Rastrigin Function (MATLAB Visualization).* GitHub Repository. Available at: `https://github.com/Whan000/Differential-Evolution-on-Rastrigin-Function-MATLAB-VIZ-.git`. Based on Storn & Price (1997) and standard DE formulations.

---

## License
```text
MIT License

Copyright (c) 2025 Phuriwat Kasamesookphaisal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
