function compile()

disp('Cloning MatConvNet ...');
system('git clone https://github.com/vlfeat/matconvnet.git /opt/matconvnet/');
cd('/opt/matconvnet/');
system('rm -rf .git');

addpath('/opt/matconvnet/matlab')

disp('Building MatConvNet ...');
vl_compilenn('verbose', 1);

end

