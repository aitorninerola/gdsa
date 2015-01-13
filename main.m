% Copyright 2015 Aitor Niñerola, Eduardo Bernal, Luís Varas, Mohamed el Bouchti
% 
% 
%     This file is part of SocialEventDetector
% 
%     SocialEventDetector is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Foobar is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with SocialEventDetector.  If not, see <http://www.gnu.org/licenses/

%% Configuration values
clear all;
close all;

conf.testf = 'files/TESTSET.mat'; %test set descriptors (or name to save them)
conf.trainf = 'files/TRAINSET.mat'; %train set descriptors (or name to save them)
conf.vlroot = 'VLFEAT_ROOT/toolbox/vl_setup'; %VLFEAT Root
conf.traindir = 'files/train/'; %Training images directory
conf.testdir = 'files/test/'; %Testing images directory
conf.kdtrees = 'files/KD_SAVED.mat'; %Load calculated kdtrees (or name to save them)
conf.veritat = 'files/anotation_matlab.csv'; %Ground truth file
conf.resname = 'results/classification.txt';
conf.tc = 600; %Num of words

run (conf.vlroot); %Load VL_FEAT

%% Generate list of training and test images
tic;
disp('Generating files list...');toc;
genera_llista(conf.traindir,'*.jpg','trainset'); %save the results in trainset.txt
genera_llista(conf.testdir, '*.jpg','testset'); %save the results in testset.txt

%% Run textual classifier
disp('Running textual classifier...');
!clasificador_textual.exe
disp('Textual classification succsessful. Results at results_textual.txt');
toc;

%% Load visual testset
if ~exist(conf.testf,'file')
    tic;
    disp('Obtaining visual descriptors of test data...');
    descriptors_visuals_2(conf.testdir,conf.veritat,conf.testf);
    toc;
end
    tic;
    disp('Loading visual descriptors of test set...');
    load(conf.testf);
    test_set = trainset;
    clear trainset;
    toc;


%% Check KDTrees or run training to create them
if ~exist(conf.kdtrees,'file')
    %Load visual trainset
if ~exist(conf.trainf,'file')
    tic;
    disp('Obtaining visual descriptors of data for training...');
    descriptors_visuals_2(conf.traindir,conf.veritat,conf.trainf);
    toc;
end
    disp('Loading visual descriptors of training set...');
    tic;
    load(conf.trainf);
    train_set = trainset;
    clear trainset;
    toc;

    tic;
    disp('Running visual training...');
    entrenador_visual(train_set,conf.tc,conf.kdtrees);
    toc;
    clear train_set;
    
end

%% Run classification
tic;
disp('Running classification...');
clasificacion_final = clasificador_final_restrictivo(test_set,'results_textual.txt', conf);
toc;
clear test_set;
%% Save final results
fileID = fopen(conf.resname,'w');
for i=1:length(clasificacion_final)
fprintf(fileID,'%s %s\n',clasificacion_final{i,1},clasificacion_final{i,2});
end
fclose(fileID);
disp(strcat('Final results saved at: ',conf.resname));


%% Run evaluation
disp('Running evaluation...');
!avaluador.exe
disp('PROGRAM FINISHED');
