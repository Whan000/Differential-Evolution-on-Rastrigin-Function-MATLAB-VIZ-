clc; clear; close all;
%% PARAMETERS
D = 2;                        % Problem dimension
NP = 1000;                    % Population size
F = 0.8;                      % Mutation factor
CR = 0.9;                     % Crossover rate
GenMax = 1000;                % Maximum generations
bounds = [-5.12, 5.12];       % Variable bounds
fitnessThreshold = 0.000001;  % Stop if best fitness < this value

%% INITIALIZATION
pop = bounds(1) + (bounds(2)-bounds(1))*rand(NP, D);
fitness = rastrigin(pop);
[xgrid, ygrid] = meshgrid(bounds(1):0.1:bounds(2));
zgrid = rastrigin([xgrid(:), ygrid(:)]);
zgrid = reshape(zgrid, size(xgrid));

% Initialize fitness history
fitnessHistory = zeros(GenMax, 1);

%% CREATE FIGURE WITH 4-PLOT LAYOUT
figure('Position',[100 100 1600 800]);
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

% Plot 1: 3D View
ax1 = nexttile(1);
surf(ax1, xgrid, ygrid, zgrid, 'EdgeColor','none');
colormap(ax1, turbo);
xlabel(ax1, 'x_1'); ylabel(ax1, 'x_2'); zlabel(ax1, 'f(x)');
title(ax1, '3D View of Rastrigin Function');
hold(ax1, 'on'); grid(ax1, 'on'); colorbar(ax1);
popDots3D = plot3(ax1, pop(:,1), pop(:,2), rastrigin(pop), 'ko', 'MarkerFaceColor','w');
bestDot3D = plot3(ax1, 0,0,0,'ro','MarkerFaceColor','r','MarkerSize',8);

% Plot 2: 2D Contour View (MAKE THIS SQUARE)
ax2 = nexttile(2);
contourf(ax2, xgrid, ygrid, zgrid, 40, 'LineColor','none');
colormap(ax2, turbo);
xlabel(ax2, 'x_1'); ylabel(ax2, 'x_2');
title(ax2, '2D Top View (Population Movement)');
axis(ax2, [bounds(1) bounds(2) bounds(1) bounds(2)]);
axis(ax2, 'equal');      % same unit scale
axis(ax2, 'square');     % square box
hold(ax2, 'on'); grid(ax2, 'on');
popDots2D = plot(ax2, pop(:,1), pop(:,2), 'ko', 'MarkerFaceColor','w');
bestDot2D = plot(ax2, 0,0,'ro','MarkerFaceColor','r','MarkerSize',8);

% Plot 3: Convergence Curve
ax3 = nexttile(3);
xlabel(ax3, 'Generation'); ylabel(ax3, 'Best Fitness');
title(ax3, 'Convergence Curve');
grid(ax3, 'on');
hold(ax3, 'on');
fitnessLine = plot(ax3, 1, 0, 'b-', 'LineWidth', 2);
xlim(ax3, [1 GenMax]);

% Plot 4: Parameter & Status Display
ax4 = nexttile(4);
axis(ax4, 'off');
title(ax4, 'Algorithm Parameters & Status', 'FontSize', 12, 'FontWeight', 'bold');

% Create parameter text display
paramText = text(ax4, 0.05, 0.95, '', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
    'FontSize', 11, 'FontName', 'Courier New', 'Interpreter', 'none');

% Initial parameter display
paramStr = sprintf(['DIFFERENTIAL EVOLUTION PARAMETERS\n' ...
    '=====================================\n\n' ...
    'Problem Dimension (D):     %d\n' ...
    'Population Size (NP):      %d\n' ...
    'Mutation Factor (F):       %.2f\n' ...
    'Crossover Rate (CR):       %.2f\n' ...
    'Max Generations:           %d\n' ...
    'Variable Bounds:           [%.2f, %.2f]\n' ...
    'Fitness Threshold:         %.6f\n\n' ...
    'STATUS\n' ...
    '=====================================\n' ...
    'Current Generation:        0\n' ...
    'Best Fitness:              N/A\n' ...
    'Best Solution:             N/A\n' ...
    'Convergence:               Not yet'], ...
    D, NP, F, CR, GenMax, bounds(1), bounds(2), fitnessThreshold);

set(paramText, 'String', paramStr);

%% MAIN LOOP
converged = false; % Flag to track convergence
for gen = 1:GenMax
    for i = 1:NP
        % --- Mutation ---
        idxs = randperm(NP, 3);
        while any(idxs == i)
            idxs = randperm(NP, 3);
        end
        x1 = pop(idxs(1), :);
        x2 = pop(idxs(2), :);
        x3 = pop(idxs(3), :);
        v = x1 + F * (x2 - x3);
        v = max(min(v, bounds(2)), bounds(1));
        % --- Crossover ---
        jrand = randi(D);
        u = pop(i, :);
        for j = 1:D
            if rand < CR || j == jrand
                u(j) = v(j);
            end
        end
        % --- Selection ---
        fu = rastrigin(u);
        if fu <= fitness(i)
            pop(i, :) = u;
            fitness(i) = fu;
        end
    end

    % --- Update visualization ---
    [bestVal, bestIdx] = min(fitness);
    bestSolution = pop(bestIdx, :);

    % Store fitness history
    fitnessHistory(gen) = bestVal;

    % Check stopping condition
    if bestVal < fitnessThreshold
        converged = true;
        fprintf('*** CONVERGENCE ACHIEVED ***\n');
        fprintf('Generation %d: Best Fitness = %.6f (below threshold %.6f)\n', gen, bestVal, fitnessThreshold);
    end

    % Update 3D
    delete(popDots3D); delete(bestDot3D);
    popDots3D = plot3(ax1, pop(:,1), pop(:,2), rastrigin(pop), 'ko', 'MarkerFaceColor','w');
    bestDot3D = plot3(ax1, bestSolution(1), bestSolution(2), bestVal, 'ro','MarkerFaceColor','r','MarkerSize',8);

    % Update 2D (KEEP SQUARE)
    delete(popDots2D); delete(bestDot2D);
    popDots2D = plot(ax2, pop(:,1), pop(:,2), 'ko', 'MarkerFaceColor','w');
    bestDot2D = plot(ax2, bestSolution(1), bestSolution(2), 'ro','MarkerFaceColor','r','MarkerSize',8);
    axis(ax2, [bounds(1) bounds(2) bounds(1) bounds(2)]);
    axis(ax2, 'equal');
    axis(ax2, 'square');

    % Update convergence curve
    set(fitnessLine, 'XData', 1:gen, 'YData', fitnessHistory(1:gen));
    ylim(ax3, [0, max(fitnessHistory(1:gen))*1.1]);

    % Update parameter display with current status
    convergenceStatus = 'Running...';
    if converged
        convergenceStatus = sprintf('ACHIEVED at Gen %d!', gen);
    end

    paramStr = sprintf(['DIFFERENTIAL EVOLUTION PARAMETERS\n' ...
        '=====================================\n\n' ...
        'Problem Dimension (D):     %d\n' ...
        'Population Size (NP):      %d\n' ...
        'Mutation Factor (F):       %.2f\n' ...
        'Crossover Rate (CR):       %.2f\n' ...
        'Max Generations:           %d\n' ...
        'Variable Bounds:           [%.2f, %.2f]\n' ...
        'Fitness Threshold:         %.6f\n\n' ...
        'STATUS\n' ...
        '=====================================\n' ...
        'Current Generation:        %d / %d\n' ...
        'Best Fitness:              %.6f\n' ...
        'Best Solution:             [%.4f, %.4f]\n' ...
        'Convergence:               %s'], ...
        D, NP, F, CR, GenMax, bounds(1), bounds(2), fitnessThreshold, ...
        gen, GenMax, bestVal, bestSolution(1), bestSolution(2), convergenceStatus);

    set(paramText, 'String', paramStr);

    sgtitle(sprintf('Differential Evolution — Generation %d', gen));
    drawnow limitrate;
    pause(0.05);

    % Display progress
    if mod(gen,10)==0 || gen==1
        fprintf('Generation %d: Best Fitness = %.6f\n', gen, bestVal);
    end

    % Break if convergence achieved
    if converged
        break;
    end
end

%% RESULTS
disp('----------------------------------------');
if converged
    fprintf('STOPPED: Fitness threshold reached at generation %d\n', gen);
else
    fprintf('COMPLETED: Maximum generations reached\n');
end
fprintf('Best Solution Found: [%.4f, %.4f]\n', bestSolution(1), bestSolution(2));
fprintf('Function Value: %.6f\n', bestVal);

%% Rastrigin Function
function f = rastrigin(X)
    A = 10;
    f = A * size(X, 2) + sum(X.^2 - A * cos(2 * pi * X), 2);
end
