clc; clear; close all;
%% PARAMETERS
D = 2;                   % Problem dimension
NP = 1000;                 % Population size
F = 0.8;                 % Mutation factor
CR = 0.9;                % Crossover rate
GenMax = 1000;            % Maximum generations
bounds = [-5.12, 5.12];  % Variable bounds
fitnessThreshold = 0.000001; % Stop if best fitness < this value
%% INITIALIZATION
pop = bounds(1) + (bounds(2)-bounds(1))*rand(NP, D);
fitness = rastrigin(pop);
[xgrid, ygrid] = meshgrid(bounds(1):0.1:bounds(2));
zgrid = rastrigin([xgrid(:), ygrid(:)]);
zgrid = reshape(zgrid, size(xgrid));

% Initialize fitness history
fitnessHistory = zeros(GenMax, 1);

%% CREATE FIGURE
figure('Position',[100 100 1400 500]);
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

ax1 = nexttile(1);
surf(ax1, xgrid, ygrid, zgrid, 'EdgeColor','none');
colormap(ax1, turbo);
xlabel(ax1, 'x_1'); ylabel(ax1, 'x_2'); zlabel(ax1, 'f(x)');
title(ax1, '3D View of Rastrigin Function');
hold(ax1, 'on'); grid(ax1, 'on'); colorbar(ax1);
popDots3D = plot3(ax1, pop(:,1), pop(:,2), rastrigin(pop), 'ko', 'MarkerFaceColor','w');
bestDot3D = plot3(ax1, 0,0,0,'ro','MarkerFaceColor','r','MarkerSize',8);

ax2 = nexttile(2);
contourf(ax2, xgrid, ygrid, zgrid, 40, 'LineColor','none');
colormap(ax2, turbo);
xlabel(ax2, 'x_1'); ylabel(ax2, 'x_2');
title(ax2, '2D Top View (Population Movement)');
axis(ax2, [bounds(1) bounds(2) bounds(1) bounds(2)]);
hold(ax2, 'on'); grid(ax2, 'on');
popDots2D = plot(ax2, pop(:,1), pop(:,2), 'ko', 'MarkerFaceColor','w');
bestDot2D = plot(ax2, 0,0,'ro','MarkerFaceColor','r','MarkerSize',8);

ax3 = nexttile(3);
xlabel(ax3, 'Generation'); ylabel(ax3, 'Best Fitness');
title(ax3, 'Convergence Curve');
grid(ax3, 'on');
hold(ax3, 'on');
fitnessLine = plot(ax3, 1, 0, 'b-', 'LineWidth', 2);
xlim(ax3, [1 GenMax]);
% Create text annotation for generation count
genText = text(ax3, 0.98, 0.98, '', 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
    'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'white', ...
    'EdgeColor', 'black', 'Margin', 3);

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
    
    % Update 2D
    delete(popDots2D); delete(bestDot2D);
    popDots2D = plot(ax2, pop(:,1), pop(:,2), 'ko', 'MarkerFaceColor','w');
    bestDot2D = plot(ax2, bestSolution(1), bestSolution(2), 'ro','MarkerFaceColor','r','MarkerSize',8);
    
    % Update convergence curve
    set(fitnessLine, 'XData', 1:gen, 'YData', fitnessHistory(1:gen));
    ylim(ax3, [0, max(fitnessHistory(1:gen))*1.1]);
    
    % Update generation counter text
    set(genText, 'String', sprintf('Gen: %d/%d\nBest: %.6f', gen, GenMax, bestVal));
    
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
fprintf('Best Solution Found: [%.4f, %.4f, %.4f]\n', bestSolution(1), bestSolution(2), bestSolution(3));
fprintf('Function Value: %.6f\n', bestVal);

%% Rastrigin Function
function f = rastrigin(X)
    A = 10;
    f = A * size(X, 2) + sum(X.^2 - A * cos(2 * pi * X), 2);
end