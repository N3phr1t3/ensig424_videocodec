% AI-WRITTEN: entry script. See AI_usage.txt.
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot, fullfile(projectRoot, 'support'), ...
    fullfile(projectRoot, 'components'));
cfg = config();
[results, experimentFolder] = run_experiments(cfg);
disp(results);
fprintf('Saved results: %s\n', experimentFolder);
