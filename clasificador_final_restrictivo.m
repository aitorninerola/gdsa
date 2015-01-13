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

function finalres = clasificador_final_restrictivo(trainset, res_textual, conf)
kdname = conf.kdtrees;
 tic;
    disp('Loading trained models...');
    load(kdname);
 toc;

%leemos los datos de la clasificacion textual
clasificacion_textual=readtable(res_textual,'Delimiter',' ','ReadVariableNames',false);
clasificacion_final=table2cell(clasificacion_textual);
%mirar el tamaño de los datos (cuantas fotos son)
ftest = genera_llista(conf.testdir, '*.jpg');
map_test = containers.Map();
map_final = containers.Map();


for i = 1:numel(ftest)
    map_test(ftest{i}) = ''; 
end

for i = 1:size(clasificacion_final,1)
       map_final(clasificacion_final{i,1}) = clasificacion_final{i,2};
end
Num=length(trainset);%misma longitud del fichero de datos de clasificacion final
%numero de clusters sera el definido en el entreno en la variable TC
K=1;
%clasificacion_visual=cell(Num,2);% variable para guardar la clasificacion visual
%clases en las que se divide el proceso
clases={'concert','conference','exhibition','fashion','protest','sports','non_event','other','theater_dance'};

disp('Classifying images...');
for i=1:Num
 
 if (isKey(map_final,trainset{1,i}.ID_imagen) && strcmpi(map_final(trainset{1,i}.ID_imagen),'non_event')) % si se ha clasificado la imagen como non_event textualmente y está en el grupo de imagenes a entrenar
   %caracteristicas de la imagen actual
   car=trainset{1,i}.caracteristiques;
   %convertirlas al formato single
   car=single(car);
   %hacer el cluster con k-means (BoF)
   [~,A]=vl_kmeans(car,TC);%la variable TC se ha definido en la parte de entrenamiento
   %bucle para calcular cuantas caracteristicas hay por centroide
   F=zeros(1,TC);%vector de 0, cuantas caracteristicas por word hay en la imagen
     for j=1:length(A)%contar cuantas caracteristicas hay por cluster en la imagen
       p=A(j);
       F(p)=F(p)+1;
     end
   %normalizar el vector de F
    tot=sum(F);
    for j=1:TC
        F(j)=F(j)/tot;
    end
    %crear un vector donde guardaremos las distancias 
    Dis=zeros(numel(clases),K);
    %buscar las distancias en el kdtree de cada clase y almacenar las distancias
    [~,D]=knnsearch(KDTree_concert,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(1,:)=D;
    [~,D]=knnsearch(KDTree_conference,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(2,:)=D;
    [~,D]=knnsearch(KDTree_exhibition,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(3,:)=D;
    [~,D]=knnsearch(KDTree_fashion,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(4,:)=D;
    [~,D]=knnsearch(KDTree_protest,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(5,:)=D;
    [~,D]=knnsearch(KDTree_sport,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(6,:)=D;
    [~,D]=knnsearch(KDTree_non_event,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(7,:)=D;
    [~,D]=knnsearch(KDTree_other,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(8,:)=D;
    [~,D]=knnsearch(KDTree_dante,F,'k',K,'Distance','cityblock'); %tamaño de I y D es de 1xK
    Dis(9,:)=D;
    %buscamos la distancia minima
    min=Dis(1,1);
     posm=1;
     for j=1:9
       for t=1:K
           if Dis(j,t)<min
             min=Dis(j,t);
             posm=j;
           end
       end
     end
        
%asignar la clase nueva a la imagen clasificada anteriormente como
%non_event

       map_final(trainset{1,i}.ID_imagen)=clases{posm};
    
 end
 
end

for i = 1:size(clasificacion_final,1)
    clasificacion_final{i,2} = map_final(clasificacion_final{i,1});
end

finalres = clasificacion_final;

end