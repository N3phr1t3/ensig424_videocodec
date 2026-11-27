function cfg = config()
% AI-WRITTEN: experiment settings and component selection. See AI_usage.txt.
root = fileparts(mfilename('fullpath'));

cfg.input.file = fullfile(root, 'data', 'foreman_qcif.y');
cfg.input.width = 176;
cfg.input.height = 144;
cfg.input.startFrame = 1;
cfg.input.numFrames = 100;

cfg.experiment.mode = 'single';       % 'single' or 'sweep'
cfg.experiment.parameter = 'quality'; % 'quality' or 'scale'
cfg.experiment.values = [10 30 50 70 90];
cfg.experiment.seed = 1;
cfg.output.root = fullfile(root, 'results');

% Change this ONE line to select another encoder/decoder pair.
cfg.codec = struct('encode', @encode_video, 'decode', @decode_video);

% Ankit: integer transform and its inverse.
cfg.components.transform = @forward_transform;
cfg.components.inverseTransform = @inverse_transform;
% Arshiya: quantization and entropy coding, including inverse operations.
cfg.components.quantize = @quantize_block;
cfg.components.dequantize = @dequantize_block;
cfg.components.entropyEncode = @entropy_encode;
cfg.components.entropyDecode = @entropy_decode;
% Jade: intra-frame prediction and filtering.
cfg.components.intraPredict = @intra_predict;
cfg.components.filter = @filter_frame;
% Armaan: motion estimation and compensation.
cfg.components.motionEstimate = @motion_estimate;
cfg.components.motionCompensate = @motion_compensate;

% The team codec must read these settings; the runner does not apply them.
cfg.params.quality = 50;
cfg.params.scale = 1;
cfg.params.transformBlockSize = [8 8]; % [rows columns]
cfg.params.intraBlockSize = [8 8];
cfg.params.motionBlockSize = [16 16];
cfg.params.searchRange = 16;
cfg.params.motionPrecision = 1;       % 1 = integer pixel, 0.5 = half pixel
cfg.params.keyFrameInterval = Inf;    % Intended baseline: first frame only
cfg.params.filterEnabled = true;

cfg.plot.makePlots = true;
cfg.plot.label = 'Group 11 codec';
cfg.plot.showProfessorBenchmark = true;
end
