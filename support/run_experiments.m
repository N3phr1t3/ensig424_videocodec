function [results, experimentFolder] = run_experiments(cfg)
% AI-WRITTEN: run the team codec and save measured experiment results.
if ~isa(cfg.codec.encode, 'function_handle') || ~isa(cfg.codec.decode, 'function_handle')
    error('Framework:Config', 'cfg.codec.encode and decode must be function handles.');
end
parameter = validatestring(cfg.experiment.parameter, {'quality','scale'});
mode = validatestring(cfg.experiment.mode, {'single','sweep'});
if strcmp(mode, 'single')
    values = cfg.params.(parameter);
else
    values = cfg.experiment.values;
end
validateattributes(values, {'numeric'}, {'vector','nonempty','real','finite'});
if strcmp(parameter, 'quality') && any(values < 1 | values > 100)
    error('Framework:Config', 'Quality values must be in [1, 100].');
elseif strcmp(parameter, 'scale') && any(values <= 0)
    error('Framework:Config', 'Scale values must be positive.');
end
validateattributes(cfg.params.quality, {'numeric'}, {'scalar','real','finite','>=',1,'<=',100});
validateattributes(cfg.params.scale, {'numeric'}, {'scalar','real','finite','positive'});
frames = read_y(cfg.input); % Input reading is outside the codec timers.
if ~isfolder(cfg.output.root)
    mkdir(cfg.output.root);
end
experimentFolder = tempname(cfg.output.root); % Never overwrite an earlier run.
mkdir(experimentFolder);
save(fullfile(experimentFolder, 'config.mat'), 'cfg');
oldRng = rng;
cleanup = onCleanup(@() rng(oldRng));
results = table();
[~, sequenceName, extension] = fileparts(cfg.input.file);
for i = 1:numel(values)
    runCfg = cfg;
    runCfg.params.(parameter) = values(i);
    rng(cfg.experiment.seed, 'twister');
    runFolder = fullfile(experimentFolder, sprintf('run_%03d', i));
    encodedFolder = fullfile(runFolder, 'encoded');
    mkdir(encodedFolder);
    save(fullfile(runFolder, 'config.mat'), 'runCfg');
    fprintf('Run %d/%d: %s = %g\n', i, numel(values), parameter, values(i));
    try
        timer = tic;
        cfg.codec.encode(frames, encodedFolder, runCfg);
        encodeSeconds = toc(timer);
        [compressedBytes, fileList] = count_bytes(encodedFolder);
        if compressedBytes <= 0
            error('Framework:Package', 'Encoder produced no nonempty files.');
        end
        timer = tic;
        decoded = cfg.codec.decode(encodedFolder);
        decodeSeconds = toc(timer);
        [~, filesAfterDecode] = count_bytes(encodedFolder);
        if ~isequal(fileList, filesAfterDecode)
            error('Framework:Package', 'Decoder changed the encoded file list or sizes.');
        end
        [metrics, perFrame] = measure_quality(frames, decoded, cfg.input.startFrame);
    catch problem
        fid = fopen(fullfile(runFolder, 'error.txt'), 'w');
        if fid >= 0
            fprintf(fid, '%s\n', getReport(problem, 'extended', 'hyperlinks', 'off'));
            fclose(fid);
        end
        fprintf(2, 'Failed run saved at: %s\n', runFolder);
        rethrow(problem); % Never write a successful row for a failed codec.
    end
    row.Run = i;
    row.Label = string(cfg.plot.label);
    row.Sequence = string([sequenceName extension]);
    row.Width = cfg.input.width;
    row.Height = cfg.input.height;
    row.StartFrame = cfg.input.startFrame;
    row.NumFrames = cfg.input.numFrames;
    row.SweepParameter = string(parameter);
    row.SweepValue = values(i);
    row.Quality = runCfg.params.quality;
    row.Scale = runCfg.params.scale;
    row.CompressedBytes = compressedBytes;
    row.Bpp = 8 * compressedBytes / numel(frames);
    row.MSE = metrics.mse;
    row.PSNR_dB = metrics.psnr;
    row.MeanFramePSNR_dB = metrics.meanFramePSNR;
    row.EncodeSeconds = encodeSeconds;
    row.DecodeSeconds = decodeSeconds;
    row.EncodeFPS = cfg.input.numFrames / encodeSeconds;
    row.DecodeFPS = cfg.input.numFrames / decodeSeconds;
    row.Encoder = string(func2str(cfg.codec.encode));
    row.Decoder = string(func2str(cfg.codec.decode));
    results = [results; struct2table(row)]; %#ok<AGROW>
    writetable(fileList, fullfile(runFolder, 'encoded_files.csv'));
    writetable(perFrame, fullfile(runFolder, 'per_frame.csv'));
    writetable(results, fullfile(experimentFolder, 'results.csv'));
end
if cfg.plot.makePlots
    plot_results(fullfile(experimentFolder, 'results.csv'), ...
        {cfg.plot.label}, cfg.plot.showProfessorBenchmark);
end
end
