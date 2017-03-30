
% converts OV saved data+stim file pair to a .mat file

clear;
close all;

myFolder = 'H:/backups/data/subject1/';
myPattern = '*.ov';

dirPattern = sprintf('%s%s', myFolder, myPattern);

files = dir(dirPattern);

for f=1:size(files,1)
	
	fn = files(f).name;
	
	loadFile = sprintf('%s%s', myFolder, fn);
	saveFile = regexprep(loadFile, '\.ov$', '\.mat');	
	
	convert_ov2mat(loadFile, saveFile);
			
end



