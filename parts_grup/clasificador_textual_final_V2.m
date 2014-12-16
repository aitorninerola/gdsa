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

%leer el fichero con los tags de cada foto y su id correspondiente
[~,~,raw]=xlsread('tags_por_comas_todos.csv');

% recorrer los tags, si encuentra coincidencias con los establecidos se 
% acaba el while y se pasa a la siguiente imagen, si no se encuentra una 
% clase, se asigna a la clase others


m=1;% filas del cell array clasificacion
tam=size(raw); % tam sera un vector [numfilas numcolumnas] para controlar el for y el while

%clasificacion de los nuevos datos
umbral=15;
for i=1:tam(1)
 t=2; %donde empiezan los tags 
 n=1; %inicializar el valor de la posicion de clasificacion temporal
 clasiftemp=cell(1,2); %cell-array con la clasificacion temporal de cada archivo (peso clase)  
  
   while(t<=tam(2)) % mientras hayan tags
       for j=1:length(rawcon)%recorrer los tags de la puntuacion
        if strcmpi(raw{i,t},rawcon{j,2})%si el tag coincide con el de la puntuacion
           if rawcon{j,2}>=umbral% si la puntuacion supera el umbral
            clasiftemp{n,1}=rawcon{j,1};%se añade la puntuacion
            clasiftemp{n,2}='concert'; %se añade la clase
            n=n+1;
           end
        end
       end
       for j=1:length(rawconf)
        if strcmpi(raw{i,t},rawconf{j,2})
          if rawconf{j,2}>=umbral 
            clasiftemp{n,1}=rawconf{j,1};
            clasiftemp{n,2}='conference';
            n=n+1;
          end
        end
       end
       for j=1:length(rawex)
        if strcmpi(raw{i,t},rawex{j,2})
           if rawex{j,2}>=umbral 
            clasiftemp{n,1}=rawex{j,1};
            clasiftemp{n,2}='exhibition';
            n=n+1;
           end
        end
       end
       for j=1:length(rawfas)
        if strcmpi(raw{i,t},rawfas{j,2})
           if rawfas{j,2}>=umbral 
            clasiftemp{n,1}=rawfas{j,1};
            clasiftemp{n,2}='fashion';
            n=n+1;
           end 
        end
       end
       for j=1:length(rawne)
        if strcmpi(raw{i,t},rawne{j,2})
           if rawne{j,2}>=umbral
            clasiftemp{n,1}=rawne{j,1};
            clasiftemp{n,2}='non_event';
            n=n+1;
           end
        end
       end
       for j=1:length(rawoth)
        if strcmpi(raw{i,t},rawoth{j,2})
          if rawoth{j,2}>=umbral 
            clasiftemp{n,1}=rawoth{j,1};
            clasiftemp{n,2}='other';
            n=n+1;
          end
        end
       end
       for j=1:length(rawpro)
        if strcmpi(raw{i,t},rawpro{j,2})
           if rawpro{j,2}>=umbral 
            clasiftemp{n,1}=rawpro{j,1};
            clasiftemp{n,2}='protest';
            n=n+1;
           end
        end
       end
       for j=1:length(rawspo)
        if strcmpi(raw{i,t},rawspo{j,2})
           if rawspo{j,2}>=umbral 
            clasiftemp{n,1}=rawspo{j,1};
            clasiftemp{n,2}='sport';
            n=n+1;
           end
        end
       end
       for j=1:length(rawdan)
        if strcmpi(raw{i,t},rawdan{j,2})
           if rawdan{j,2}>=umbral 
            clasiftemp{n,1}=rawdan{j,1};
            clasiftemp{n,2}='theater_dance';
            n=n+1;
           end
        end
       end
   t=t+1;
   end %final del while 
 %buscar el tag con mayor peso de la clasificacion temporal y asignar esta
 %clase al nuevo archivo
 max{1,1}=clasiftemp{1,1}; %establecemos como maximo el primer valor
 max{1,2}=clasiftemp{1,2}; %clase del valor maximo
 
 for p=1:length(clasiftemp) 
     if clasiftemp{p,1}>max{1,1}
       max{1,1}=clasiftemp{p,1};
       max{1,2}=clasiftemp{p,2};%clase con ponderacion maxima
     end
 end
 
%finalmente clasificamos poniendo el valor de mayor peso
  clasificacion{m,1}=raw{i,1}; %id
  clasificacion{m,2}=max{1,2}; %clase final
  m=m+1;
  
end
   
fileID = fopen('results_v2','w');
for i=1:length(clasificacion)
fprintf(fileID,'%s %s\n',clasificacion{i,1},clasificacion{i,2});
end
fclose(fileID);