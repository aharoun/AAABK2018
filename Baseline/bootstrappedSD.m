% Calculates the standard error of the parameters based on bootstrap
global alg;
initalg('baseline');

alg.bootstrap = 1;		

filename = 'bootstrapResult.mat';
numBoot  = 1000;  % number of bootstrap iterations

if ~exist(filename)
	disp('No result file found. Creating one...');
	paramBoots = [];
	save(filename, 'paramBoots');
else
	x = input('Do you want to overide the existing result file? 1/0');
	if x == 1
		disp('Result file is overidden.')
		paramBoots = [];
		save(filename, 'paramBoots');	
	else
		error('Operation aborted...');
	end
end

data    = csvread(['moments' filesep 'baselineMomentCov.csv']);
momMean = data(:,2);
momCov  = data(:,3:end);

disp('BOOTSTRAP STARTS HERE')
for i = 1:numBoot
	
	momBoot = mvnrnd(momMean,momCov);      % drawing moments from multivariate normal distribution
	csvwrite(alg.mmtBoot_file,momBoot');	   % write bootstrapped moments to data file which will be used in estimation
	
	smm;					   		       % estimation with bootstrapped data	
	parEst = parse_params(['temp_files' filesep 'params_best.txt']);

	load(filename);

	paramBoots = [paramBoots ; i parEst];

	save(filename, 'paramBoots'); 
	fprintf('NUMBER OF BOOTSTRAP\t: %i\n',i);   
end

disp('Bootstrap is done!')

load(filename);

% Calculate standard errors of the parameters based on bootstrap
stdParams = std(paramBoots);