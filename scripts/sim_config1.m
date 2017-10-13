
% Disturbances and failures begin at the start_hour

% begin setup
run([init_dir,'Mode_1_Init.m']);

%run('Mode_3_Init.m')
% end setup

models=["MultiLoop_mode1"];

save_path_base = [database_dir, '/data/simulations/sim_config_1/'];
mkdir(save_path_base);


%disturbances

failures = zeros(1, 13);
failures_values= zeros(1, 13);

dist_active = [1 zeros(1,27)];
startTimeDist = 10;
sizeRep = 1;

% Simulation ID
if isempty(sims)
    sim_id = 1;
else
    sim_id = sims(end, 1);
end

for indexModel=1:size(models,2)
    disp("init simulation");
    for dist_index = 1:28
        dist_path_folder = strcat(save_path_base,'dist', int2str(dist_index),'/');
        mkdir(dist_path_folder);
        dist = [zeros(1,29);[startTimeDist dist_active]];
        disp(strcat('Dist: ', int2str(dist_index)));
        for index=1:sizeRep
            te_seed = index;
            sim_path = strcat('sim_', int2str(index));
            disp(sim_path);
            sim(models_dir + models(indexModel));
            mkdir(strcat(dist_path_folder,sim_path));
            csvwrite(strcat(dist_path_folder, sim_path,'/simout_tbase_', mat2str(Ts_base), '.csv'), simout);
            csvwrite(strcat(dist_path_folder, sim_path,'/tout','.csv'), tout);
            
            % Save Current Simulation
            sims = [sims; sim_id, Ts_base, te_seed, 72];
            sim_dists = [sim_dists; sim_id, dist_index, startTime, -1];
            save([database_dir, 'reg_db.mat'], "sims", "dists", "fails", "sim_dists", "sim_fails");
            sim_id = sim_id + 1;
        end
        dist_active = circshift(dist_active,1);
    end
    disp("end simulation");
end


%failures

dist = zeros(1,29);
startTimeFail = 10;
type_fail = [0,25,50,75,100];

failures_active = [1 zeros(1,11)];
failures_values_active = zeros(1,12);
sizeFailRep = 1;

for indexModel=1:size(models,2)
    disp("init simulation");
    for index_fail = 1:1:size(failures_active, 2)
        failures = [0 zeros(1,12);[startTimeFail failures_active]];
        fail_path_folder = strcat(save_path_base,'failure_', int2str(index_fail),'/');
        mkdir(fail_path_folder);
        disp(strcat('Fail: ', int2str(index_fail)));
        for index_type_fail =1:size(type_fail,2)
            fail_val = type_fail(index_type_fail);
            failures_values_active(index_fail) = fail_val;
            failures_values = [startTimeFail failures_values_active];
            disp(strcat('Fail Type: ', int2str(fail_val)));
            for index_fail_rep=1:sizeFailRep
                te_seed = index_fail_rep;
                sim_path = strcat('/fail_type_', int2str(fail_val),'/sim_', int2str(index_fail_rep));
                mkdir(strcat(fail_path_folder,sim_path));
                disp(strcat('sim_', int2str(index_fail_rep)));
                sim(models_dir + models(indexModel));
                csvwrite(strcat(fail_path_folder,sim_path, '/simout_tbase_', mat2str(Ts_base), '.csv'), simout);
                csvwrite(strcat(fail_path_folder, sim_path,'/tout','.csv'), tout);
                
                % Save Current Simulation
                sims = [sims; sim_id, Ts_base, te_seed, 72];
                sim_fails = [sim_fails; sim_id, index_fail, fail_val, startTimeFail, -1];
                save([database_dir, 'reg_db.mat'], "sims", "dists", "fails", "sim_dists", "sim_fails");
                sim_id = sim_id + 1;
            end
        end
        failures_values_active(index_fail) = 0;
        failures_active = circshift(failures_active,1);
    end
    disp("end simulation");
end