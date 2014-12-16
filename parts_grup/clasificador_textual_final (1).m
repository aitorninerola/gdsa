%lectura de los ficheros con las caracteristicas necesarias para la
%clasificacion textual, en este caso lista de tags y numero de apariciones
%segun la clase.
clear all;
[~,~,rawcon]=xlsread('tags_concert.csv');
[~,~,rawconf]=xlsread('tags_conference.csv');
[~,~,rawex]=xlsread('tags_exhibition.csv');
[~,~,rawfas]=xlsread('tags_fashion.csv');
[~,~,rawne]=xlsread('tags_non-event.csv');
[~,~,rawoth]=xlsread('tags_other.csv');
[~,~,rawpro]=xlsread('tags_protest.csv');
[~,~,rawspo]=xlsread('tags_sports.csv');
[~,~,rawdan]=xlsread('tags_theater-dance.csv');

% seleccionar el que mas aparece (el primero del fichero) y asignar el tag
% para la clasificacion

clases{1,1}=rawcon{1,2};
clases{1,2}='concert';
clases{2,1}=rawconf{1,2}; 
clases{2,2}='conference';
clases{3,1}=rawex{1,2};
clases{3,2}='exhibition';
clases{4,1}=rawfas{1,2};
clases{4,2}='fashion';
clases{5,1}=rawpro{1,2};
clases{5,2}='protest';
clases{6,1}=rawspo{1,2};
clases{6,2}='sport';
clases{7,1}=rawdan{1,2};
clases{7,2}='theater_dance';
clases{8,1}='other';
clases{8,2}='other';

%leer el fichero con los tags de cada foto y su id correspondiente
 [~,~,raw]=xlsread('tags_por_comas_todos.csv');

% recorrer los tags, si encuentra coincidencias con los establecidos se 
% acaba el while y se pasa a la siguiente imagen, si no se encuentra una 
% clase, se asigna a la clase others


n=1;% filas de la estructura clasificacion
tam=size(raw); % tam sera un vector [numfilas numcolumnas] para controlar el for y el while

%clasificacion de los nuevos datos

for i=1:tam(1)
 c=0; % avisa de clasificado
 nt=0; % avisa que ya no hay mas tags
 t=2; %donde empiezan los tags
 
  while (c~=1) 
    tag=raw{i,t}; 
     switch tag
         case clases{1,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{1,2};
          n=n+1;
          c=1;
         case clases{2,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{2,2};
          n=n+1; 
          c=1;
          case clases{3,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{3,2};
          n=n+1;
          c=1;
          case clases{4,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{4,2};
          n=n+1;
          c=1;
          case clases{5,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{5,2};
          n=n+1;
          c=1;
          case clases{6,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{6,2};
          n=n+1;
          c=1;
          case clases{7,1}
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{7,2};
          n=n+1;
          c=1;
     end %final del siwtch
   
     if t==tam(2)
         break
     else
      t=t+1; % sigo mirando los tags si no he podido clasificar la imagen
     end
 end
  
      if t==tam(2) % si no hay tags y no he clasificado la imagen, esta pasa a ser de la clase others
          clasificacion{n,1}=raw{i,1};
          clasificacion{n,2}=clases{8,2};
          n=n+1;
      else
              
      end
  
end
   
fileID = fopen('results','w');
for i=1:length(clasificacion)
fprintf(fileID,'%s %s\n',clasificacion{i,1},clasificacion{i,2});
end
fclose(fileID);
