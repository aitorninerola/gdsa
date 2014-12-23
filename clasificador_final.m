function finalres = clasificador_final(trainset, res_textual, kdname)

    tic;
    disp('Loading trained models...');
    load(kdname);
    toc;

%leemos los datos de la clasificacion textual
clasificacion_textual=readtable(res_textual,'Delimiter',' ','ReadVariableNames',false);
clasificacion_final=table2cell(clasificacion_textual);
%mirar el tamaño de los datos (cuantas fotos son)
Num=length(trainset);
%numero de clusters sera el definido en el entreno en la variable TC
K=1;
clasificacion_visual=cell(Num,2);% variable para guardar la clasificacion visual
%clases en las que se divide el proceso
clases={'concert','conference','exhibition','fashion','protest','sports','non_event','other','theater_dance'};
for i=1:Num
    %caracteristicas de la imagen actual
 car=trainset{1,i}.caracteristiques;
 %convertirlas al formato single
 car=single(car);
 %hacer el cluster con k-means (BoF)
 [C,A]=vl_kmeans(d,TC);%la variable TC se ha definido en la parte de entrenamiento
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
        
%asignar la clase a la nueva imagen
   switch posm
       case 1
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 2
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 3
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 4
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 5
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 6
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 7
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 8
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
       case 9
           clasificacion_visual{i,1}=trainset{1,i}.ID_imagen;
           clasificacion_visual{i,2}=clases{posm};
   end
   
end
%comparar los resutlados y sacar una clasificacion final
%clasificacion_final=cell(Num,2); % variable donde se guardara la clasificacion final
for i=1:Num
    %comparar clasif_textual con clasificacion
   if strcmpi(clasificacion_final{i,2},'non_event') %buscamos los clasificados como no evento en la clasificacion textual
       for j=1:Num %buscar el id en la clasificacion visual
         if strcmpi(clasificacion_visual{j,1},clasificacion_final{i,1}) %los id's de textual y visual coinciden
             clasificacion_final{i,1}=clasificacion_visual{i,1};
             clasificacion_final{i,2}=clasificacion_visual{j,2}; % ponemos la clase del visual a los textuales asignados como non_event
             break %una vez encontrado el id y asignada la clase, salir del for
         end
       end
   end

end

finalres = clasificacion_final;

end