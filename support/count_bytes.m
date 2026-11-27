function [totalBytes, files] = count_bytes(folder)
% AI-WRITTEN: count actual bytes of EVERY file, including nested side files.
if ~isfolder(folder)
    error('Framework:Package', 'Encoded folder does not exist: %s', folder);
end
[names, sizes] = scan_folder(folder, '');
files = table(string(names), sizes, 'VariableNames', {'File','Bytes'});
files = sortrows(files, 'File');
totalBytes = sum(files.Bytes);
end

function [names, sizes] = scan_folder(root, relative)
names = cell(0, 1);
sizes = zeros(0, 1);
entries = dir(fullfile(root, relative));
for i = 1:numel(entries)
    entry = entries(i);
    if strcmp(entry.name, '.') || strcmp(entry.name, '..')
        continue;
    end
    name = fullfile(relative, entry.name);
    if entry.isdir
        [childNames, childSizes] = scan_folder(root, name);
        names = [names; childNames]; 
        sizes = [sizes; childSizes]; 
    else
        names{end+1, 1} = name; 
        sizes(end+1, 1) = entry.bytes; 
    end
end
end
