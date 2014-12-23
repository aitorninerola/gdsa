%Social Event Detector
%GDSA 2014- Grup 3.1 (Aitor, Edu, Hannes, Luis, Moha)

% descriptors_visuals(ndir, train, name)
% 
% Creates a file with the name 'name' which contains the visual descriptors
% of the files in the 'ndir' and the real class for posterior evaluation

function descriptors_visuals(ndir, train, fname)

ratio = 0.25; %image reduction for processing

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
I= imresize(imread(strcat(ndir,archivo)),ratio);% lee la primera imagen
I= single(rgb2gray(I));

[f,d] = vl_phow(I); %cogemos sus caracteristicas segun el algoritmo SIFT
classe = map_class(ID_ima);  

v_carac= struct('ID_imagen',ID_ima,'caracteristiques', d, 'classe', classe);

trainset{numel(trainset)+1} = v_carac;

end

save (fname,'trainset','-v7.3');
clear all;

end