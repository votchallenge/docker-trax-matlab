function compile()

disp('Cloning MexOpenCV ...');
system('git clone https://github.com/kyamagu/mexopencv.git /opt/mexopencv/');
cd('/opt/mexopencv/');
system('git checkout v2.4');
system('rm -rf .git');

% Removing SIFT and SURF support because we cannot build them with Ubuntu's OpenCV
system('bash utils/remove_nonfree.sh');

disp('Building MexOpenCV ...');
system('make');

end

