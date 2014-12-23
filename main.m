%Social Event Detector
%GDSA 2014- Grup 3.1 (Aitor, Edu, Hannes, Luis, Moha)

%% Configuration values
conf.testf = 'files/demotest.mat'; %testset name (.mat files)
conf.trainf = 'files/demotrain.mat'; %trainset name (.mat files)
conf.vlroot = 'D:\Documentos\MATLAB\vlfeat/toolbox/vl_setup'; %VLFEAT Root
conf.traindir = 'C:\Users\Aitor\Google Drive\GDSA PROJECT\FINAL\demofiles\train\'; %Training images directory
conf.testdir = 'C:\Users\Aitor\Google Drive\GDSA PROJECT\FINAL\demofiles\test\'; %Testing images directory
conf.kdtrees = 'files/KD_demo.mat'; %Load calculated kdtrees
conf.veritat = 'C:\Users\Aitor\Google Drive\GDSA PROJECT\data\anotacio\train2.csv'; %Ground truth file
conf.resname = 'results/31.txt';
conf.tc = 200; %Num of clusters to split data

run (conf.vlroot); %Load VL_FEAT

%% Generate list of training and test images
tic;
disp('Generating files list...');toc;
genera_llista(conf.traindir,'*.jpg','trainset');
genera_llista(conf.testdir, '*.jpg','testset');

%% Run textual classifier
disp('Running textual classifier...');
!clasificador_textual.exe

%% Load visual trainset
if ~exist(conf.trainf,'file')
    tic;
    disp('Obtaining visual descriptors...');
    descriptors_visuals(conf.traindir,conf.veritat,conf.trainf);
    toc;
end
    disp('Loading trainset...');
    tic;
    load(conf.trainf);
    toc;


%% Load visual testset
if ~exist(conf.testf,'file')
    tic;
    disp('Obtaining visual descriptors...');
    descriptors_visuals(conf.testdir,conf.veritat,conf.testf);
    toc;
end
    tic;
    disp('Loading test data...');
    load(conf.testf);
    toc;


%% Load kdtrees or run training
if ~exist(conf.kdtrees,'file')
    tic;
    disp('Running visual training...');
    entrenador_visual(trainset,conf.tc,conf.kdtrees);
    toc;
    
end


    %% Run classification
tic;
disp('Running classification...');
clasificacion_final = clasificador_final(trainset,'results_textual.txt', conf.kdtrees);
toc;

%% Save final results
fileID = fopen(conf.resname,'w');
for i=1:length(clasificacion_final)
fprintf(fileID,'%s %s\n',clasificacion_final{i,1},clasificacion_final{i,2});
end
fclose(fileID);

clear trainset;
%% Run evaluation
disp('Running evaluation...');
!evaluation.py