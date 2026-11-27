function figures = plot_results(csvFiles, labels, showBenchmark)
% AI-WRITTEN: compare saved runs; save editable .fig files and PNG copies.
% Example: plot_results({'baseline.csv','improved.csv'}, {'Baseline','Improved'}, true)
if ischar(csvFiles) || isstring(csvFiles)
    csvFiles = cellstr(csvFiles);
end
if nargin < 2 || isempty(labels)
    labels = cell(size(csvFiles));
    for i = 1:numel(csvFiles)
        [~, labels{i}] = fileparts(fileparts(csvFiles{i}));
    end
end
labels = cellstr(string(labels));
if numel(labels) ~= numel(csvFiles)
    error('Framework:Plot', 'Supply one legend label for each CSV file.');
end
if nargin < 3
    showBenchmark = false;
end
tables = cell(size(csvFiles));
for i = 1:numel(csvFiles)
    tables{i} = readtable(csvFiles{i}, 'TextType', 'string');
    if isempty(tables{i})
        error('Framework:Plot', 'Results CSV is empty.');
    end
end
% Curves must use the same sequence, dimensions, and frame range.
keys = {'Sequence','Width','Height','StartFrame','NumFrames'};
reference = tables{1}(1, keys);
for i = 1:numel(tables)
    if ~isequal(unique(tables{i}(:,keys), 'rows'), reference)
        error('Framework:Plot', 'Compare the same sequence, resolution, and frame range.');
    end
end
figures(1) = figure('Name', 'Rate and quality', 'Color', 'w');
ax = axes(figures(1));
hold(ax, 'on');
for i = 1:numel(tables)
    t = sortrows(tables{i}, 'Bpp');
    plot(ax, t.Bpp, t.PSNR_dB, '-o', 'DisplayName', labels{i});
end
matchesBenchmark = strcmp(reference.Sequence, 'foreman_qcif.y') && ...
    reference.Width == 176 && reference.Height == 144 && ...
    reference.StartFrame == 1 && reference.NumFrames == 100;
if showBenchmark && matchesBenchmark
    plot(ax, [0.38 0.61 0.80 1.07 1.93], [29.12 31.27 32.64 34.10 38.78], ...
        '--s', 'DisplayName', 'Professor iteration 0 (reported)');
elseif showBenchmark
    warning('Framework:Benchmark', 'Professor curve omitted: sequence or frame range differs.');
end
xlabel(ax, 'Rate (bits per original Y pixel)');
ylabel(ax, 'PSNR from pooled MSE (dB)');
title(ax, 'Rate versus quality');
grid(ax, 'on');
legend(ax, 'show', 'Location', 'best', 'Interpreter', 'none');

figures(2) = figure('Name', 'Codec timing', 'Color', 'w');
ax = axes(figures(2));
hold(ax, 'on');
for i = 1:numel(tables)
    t = sortrows(tables{i}, 'Bpp');
    plot(ax, t.Bpp, t.EncodeSeconds, '-o', 'DisplayName', [labels{i} ' encode']);
    plot(ax, t.Bpp, t.DecodeSeconds, '--s', 'DisplayName', [labels{i} ' decode']);
end
xlabel(ax, 'Rate (bits per original Y pixel)');
ylabel(ax, 'Time for all selected frames (s)');
title(ax, 'Encoder and decoder timing');
grid(ax, 'on');
legend(ax, 'show', 'Location', 'best', 'Interpreter', 'none');
outputFolder = fileparts(csvFiles{1});
names = {'rate_quality', 'timing'};
for i = 1:numel(figures)
    savefig(figures(i), fullfile(outputFolder, [names{i} '.fig']));
    print(figures(i), fullfile(outputFolder, [names{i} '.png']), '-dpng', '-r150');
end
end
