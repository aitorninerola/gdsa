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

% descriptors_visuals(ndir, train, name)
% 
% Creates a file with the name 'name' which contains the visual descriptors
% of the files in the 'ndir' and the real class for posterior evaluation

function descriptors_visuals_2(ndir, train, fname)

ratio = 0.5; %image reduction for processing
conf.phowOpts = {'Verbose', 0, 'Sizes', 7, 'Step', 5} ;

formats = '%s%s'; %Format de les dades en cada columna
headerLines = 0; %ATENCIÓ-Tenim una primera fila amb la capcelera: document_id, event_types.
delimiter = ',';
[class{1:2}] = textread(train, formats,'headerlines', headerLines, 'delimiter', delimiter);

v_id = [class{1}];
v_class = [class{2}];
length_clas = length(v_class);

map_class = containers.Map();

for i=1:length_clas
    map_class(v_id{i}) = v_class{i};
end

ndir2 = strcat(ndir,'*.jpg');
lee_archivos = dir(ndir2); %el formato de imagen puede ser modificado.

trainset = {};
for k = 1:length(lee_archivos) %recorre número de archivos guardados en el directorio
archivo = lee_archivos(k).name; %Obtiene el nombre de los archivos
 %Recore el diretorio
[PATH,NAME,EXT] = fileparts(archivo); %quitamos la extensión .jpg para guardar en el ID_imagen
ID_ima=fullfile(NAME);
im = imresize(imread(strcat(ndir,archivo)),ratio);% lee la primera imagen
im = single(rgb2gray(im));

[~,d] = vl_phow(im,conf.phowOpts{:}); %cogemos sus caracteristicas segun el algoritmo SIFT    y nos quedamos con un max de 4000
if size(d,2) > 4000
r = randperm(size(d,2),4000);
d = d(:,r);
end
classe = map_class(ID_ima);  

v_carac= struct('ID_imagen',ID_ima,'caracteristiques', d, 'classe', classe);

trainset{numel(trainset)+1} = v_carac;

end

save (fname,'trainset','-v7.3');
clear all;

end
