%{
 * Copyright (C) 2013-2025, The Regents of The University of Michigan.
 * All rights reserved.
 * This software was developed in the Biped Lab (https://www.biped.solutions/) 
 * under the direction of Jessy Grizzle, grizzle@umich.edu. This software may 
 * be available under alternative licensing terms; contact the address above.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of the Regents of The University of Michigan.
 * 
 * AUTHOR: Bruce JK Huang (bjhuang[at]umich.edu)
 * WEBSITE: https://www.brucerobot.com/
%}

%% General parameters
clear, clc
scene = 6; % Scene number
show_statistics = 1;
addpath('/home/brucebot/workspace/griztag/src/matlab/matlab/slider/intrinsic_latest')


%% Plotting parameters
num_handles = 8;
start_number = 1;
name = "testing";
fig_handles = createFigHandleWithNumber(num_handles, start_number, name);


%% Create objects
disp("- Generating obstacles...")
[object_list, color_list] = CreateObstacles(scene);

% Plot all polygons
plotMultiplePolygonsVertices(fig_handles(2), object_list, color_list)

% Workspace boundary
% boundary.x = [20, -20];
% boundary.y = [10, -10];
% boundary.z = [10, -10];
boundary.x = [20, -20];
boundary.y = [10, -10];
boundary.z = [10, -10];
boundary.vertices = createBoxVertices(boundary);
boundary.faces = createBoxFaces(boundary.vertices);
scatter3(fig_handles(2), [boundary.vertices.x], [boundary.vertices.y], [boundary.vertices.z], 'fill')

plotOriginalAxis(fig_handles(2), 1)
viewCurrentPlot(fig_handles(2), "3D environment (Scene " + num2str(scene) + ")")


%% LiDAR properties
disp("- Loading LiDAR properties...")
LiDAR_opts.noise_model = 1; % 1: simpleMechanicalNoiseModel
LiDAR_opts.properties.rpm = 600;
LiDAR_opts.properties.range = 50;
LiDAR_opts.centriod = [0 0 0];
LiDAR_opts.properties = getLiDARPreperties("UltraPuckV2", LiDAR_opts.properties);
[LiDAR_opts.properties.ring_elevation, ...
 LiDAR_opts.properties.ordered_ring_elevation] = parseLiDARStruct(LiDAR_opts.properties.elevation_struct, 'ring_', LiDAR_opts.properties.beam);


%% Simulate environment
disp("- Simulating LiDAR environment given provided obstacles...")
[object_list, LiDAR_ring_points, all_points]= simulateLiDAR(object_list, boundary, LiDAR_opts);


%% Plotting simulation
disp("- Drawing simulated LiDAR environment...")
% scatter3(fig_handle(3), all_points(1, :), all_points(2, :), all_points(3, :), 'b.')
% cla(fig_handle(3))

for beam_num = 1:LiDAR_opts.properties.beam
    scatter3(fig_handles(3), LiDAR_ring_points(beam_num).points.x, ...
                             LiDAR_ring_points(beam_num).points.y, ...
                             LiDAR_ring_points(beam_num).points.z, '.')
    hold(fig_handles(3), 'on')
%     text(fig_handle(3), max(LiDAR_ring_points(beam_num).points.x), ...
%                         max(LiDAR_ring_points(beam_num).points.y), ...
%                         min(LiDAR_ring_points(beam_num).points.z), num2str(beam_num))
end


plotMultiplePolygonsVertices(fig_handles(3), object_list, color_list)
plotOriginalAxis(fig_handles(3), 1, '-k')
viewCurrentPlot(fig_handles(3), "LiDAR simulation (Scene " + num2str(scene) + ")")
set(fig_handles(3), 'visible', 'off')
set(fig_handles(3), 'Color', 'b')


%% Plotting points on polygons
% cla(fig_handle(4))
disp("- Drawing points on obstacles...")
plotMultiplePolygonsVertices(fig_handles(4), object_list, color_list)
% scatter3(fig_handle(4), [boundary.vertices.x], [boundary.vertices.y], [boundary.vertices.z], 'fill')
plotOriginalAxis(fig_handles(4), 1, '-k')
for object = 1:length(object_list)
    scatter3(fig_handles(4), [object_list(object).ring_points.x], ...
                             [object_list(object).ring_points.y], ...
                             [object_list(object).ring_points.z], color_list(object), '.')
    
    % Plot on separated plots
    scatter3(fig_handles(4+object), [object_list(object).ring_points.x], ...
                                    [object_list(object).ring_points.y], ...
                                    [object_list(object).ring_points.z], color_list(object), '.')
    plotConnectedVerticesStructure(fig_handles(4+object), object_list(object).object_vertices, 'b')
end
view_angle = [-86, 14];
viewCurrentPlot(fig_handles(4), "Rings on Objects (Scene " + num2str(scene) + ")", view_angle)
view_angle = [90, 0];
viewCurrentPlot(fig_handles(5), "Object 1 (Scene " + num2str(scene) + ")", view_angle)
viewCurrentPlot(fig_handles(6), "Object 2 (Scene " + num2str(scene) + ")", view_angle)
viewCurrentPlot(fig_handles(7), "Object 3 (Scene " + num2str(scene) + ")", view_angle)
viewCurrentPlot(fig_handles(8), "Object 4 (Scene " + num2str(scene) + ")", view_angle)

if show_statistics
    fprintf("\n\n\n")
    disp("==================")
    disp("--- Statistics ---")
    disp("==================")
    fprintf("\n\n------------------------\n")
    disp("- std on each target")
    disp("------------------------")
    for object = 1:length(object_list)
        fprintf("\n--- Object %i\n", object)
        fprintf("std of x: %f\n", std([object_list(object).ring_points.x]))
        fprintf("std of y: %f\n", std([object_list(object).ring_points.y]))
        fprintf("std of z: %f\n", std([object_list(object).ring_points.z]))
    end

    fprintf("\n\n------------------------\n")
    disp("- Noise on each ring")
    disp("------------------------")
    struct2table([LiDAR_ring_points.noise_model])
    
%     fprintf("\n\n------------------------\n")
%     disp("- Numbers of points on each ring")
%     disp("------------------------")
%     for beam_num = 1:LiDAR_opts.properties.beam
%         fprintf("\n--- ring %i\n", beam_num)
%         fprintf("num_points of x: %i\n", length(LiDAR_ring_points(beam_num).points.x))
%         fprintf("num_points of y: %i\n", length(LiDAR_ring_points(beam_num).points.y))
%         fprintf("num_points of z: %i\n", length(LiDAR_ring_points(beam_num).points.z))
%     end
end


%% Intrinsic Calibration

opts.method = 1; % Lie; Spherical
opts.iterative = 1;
opts.show_results = 1;


opt_formulation = ["Lie","Spherical"]; % Lie or Spherical
opts.num_scans = 1;
opts.num_iters = 10;
opts.num_beams = LiDAR_opts.properties.beam;
num_targets = length(object_list);

if (opt_formulation(opts.method) == "Lie")
    data_split_with_ring_cartesian = cell(1,num_targets);
    data_split_with_ring_cartesian_original = cell(1,num_targets);
    
    disp("Parsing data...")
    for t = 1:num_targets
        data_split_with_ring_cartesian{t} = splitPointsBasedOnRing(object_list(t).points_mat, opts.num_beams);
    end 
    data_split_with_ring_cartesian_original = data_split_with_ring_cartesian;
    
    disp("Optimizing using Lie Group method...")
    if ~opts.iterative
       opts.num_iters = 1;
    end
    
    distance = []; % if re-run, it will show error of "Subscripted assignment between dissimilar structures"
    distance(opts.num_iters).ring(opts.num_beams) = struct();
    for k = 1: opts.num_iters
        fprintf("--- Working on %i/%i\n", k, opts.num_iters)
        [delta, plane, valid_rings_and_targets] = estimateIntrinsicLie(opts.num_beams, num_targets, opts.num_scans, data_split_with_ring_cartesian);
        if k == 1
            distance_original = point2PlaneDistance(data_split_with_ring_cartesian, plane, opts.num_beams, num_targets); 
        end
        % update the corrected points
        data_split_with_ring_cartesian = updateDataRaw(opts.num_beams, num_targets, data_split_with_ring_cartesian, delta, valid_rings_and_targets, opt_formulation(opts.method));
        distance(k) = point2PlaneDistance(data_split_with_ring_cartesian, plane, opts.num_beams, num_targets); 
    end

elseif (opt_formulation(opts.method) == "Spherical")
    % preprocess the data
    spherical_data = cell(1,num_targets);
    data_split_with_ring = cell(1, num_targets);
    data_split_with_ring_cartesian = cell(1, num_targets);

    disp("Parsing data...")
    for t = 1:num_targets
        spherical_data{t} = Cartesian2Spherical(object_list(t).ring_points.points_mat);
        data_split_with_ring{t} = splitPointsBasedOnRing(spherical_data{t}, opts.num_beams);
        data_split_with_ring_cartesian{t} = splitPointsBasedOnRing(object_list(t).ring_points.points_mat, opts.num_beams);
    end
    
    disp("Optimizing using a mechanical model...")
    if ~opts.iterative
       opts.num_iters = 1;
    end
    distance = []; % if re-run, it will show error of "Subscripted assignment between dissimilar structures"
    distance(opts.num_iters).ring(opts.num_beams) = struct(); 
    
     % iteratively optimize the intrinsic parameters
    for k = 1: opts.num_iters
        fprintf("--- Working on %i/%i\n", k, opts.num_iters)
        [delta, plane, valid_rings_and_targets] = estimateIntrinsicFromMechanicalModel(opts.num_beams, num_targets, opts.num_scans, data_split_with_ring, data_split_with_ring_cartesian);
        if k == 1
            distance_original = point2PlaneDistance(data_split_with_ring_cartesian, plane, opts.num_beams, num_targets); 
        end
        
        % update the corrected points
        data_split_with_ring = updateDatacFromMechanicalModel(opts.num_beams, num_targets, data_split_with_ring, delta, valid_rings_and_targets);
        data_split_with_ring_cartesian = updateDataRaw(opts.num_beams, num_targets, data_split_with_ring, delta, valid_rings_and_targets, opt_formulation(opts.method));
        distance(k) = point2PlaneDistance(data_split_with_ring_cartesian, plane, opts.num_beams, num_targets); 
    end
end
disp('Done optimization')


%% show numerical results
disp("Showing numerical results...")
disp("Showing current estimate")
results = struct('ring', {distance(end).ring(:).ring}, ...
                 'num_points', {distance(end).ring(:).num_points}, ...
                 'mean_original', {distance_original.ring(:).mean}, ...
                 'std_original', {distance_original.ring(:).std}, ...
                 'mean_diff', num2cell([distance_original.ring(:).mean] - [distance(end).ring(:).mean]), ...
                 'std_diff', num2cell([distance_original.ring(:).std] - [distance(end).ring(:).std]), ...
                 'mean_diff_in_mm', num2cell(([distance_original.ring(:).mean] - [distance(end).ring(:).mean]) * 1e3), ...
                 'std_diff_in_mm', num2cell(([distance_original.ring(:).std] - [distance(end).ring(:).std])* 1e3));
struct2table(distance(end).ring(:))
disp("Showing comparison")
struct2table(results)

% check if ring mis-ordered
disp("If the rings are mis-ordered...")
checkRingOrderWithOriginal(data_split_with_ring_cartesian_original, data_split_with_ring_cartesian, num_targets, opts.num_beams)


fprintf("\n\n\n")
disp("=================")
disp("Done All Process!")
disp("=================")