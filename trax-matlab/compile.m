function compile()

%system('cp /'

trax_path = getenv('TRAX_SOURCE');

lib_path = '/usr/local/lib';

disp('Building traxserver MEX file ...');
arguments = {['-I', fullfile(trax_path, 'include')], ...
    fullfile(trax_path, 'support', 'matlab', 'traxserver.cpp'), ...
    fullfile(trax_path, 'support', 'matlab', 'helpers.cpp'), ...
    '-ltrax', ['-L', lib_path]};

arguments{end+1} = '-lut';

mex(arguments{:});

disp('Building traxclient MEX file ...');
arguments = {['-I', fullfile(trax_path, 'include')], ['-I', fullfile(trax_path, 'support', 'client', 'include')], ...
    fullfile(trax_path, 'support', 'matlab', 'traxclient.cpp'), ...
    fullfile(trax_path, 'support', 'matlab', 'helpers.cpp'), ...
    '-ltrax', '-ltrax_client', ['-L', lib_path]};

arguments{end+1} = '-lut';

mex(arguments{:});

mkdir('/opt/mex');

movefile(['traxserver.', mexext], '/opt/mex');
movefile(['traxclient.', mexext], '/opt/mex');

end

