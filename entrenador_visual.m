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

% entrenador_visual(trainset, num_words, filename)
% 
% Saves in the file 'filename' the KDTrees created wit the KMeans (num_words) clustering of
% data from the trainset.

function entrenador_visual(trainset, TC, kdtreename)

numim=length(trainset);

cn1=1;cn2=1;cn3=1;cn4=1;cn5=1;cn6=1;cn7=1;cn8=1;cn9=1;cn10=1;

for i=1:numim
%conseguir la caracteristica de la imagen que se esta leyendo
% if i~=no_info
d=trainset{1,i}.caracteristiques;

%convertirlas al formato single
d=single(d);
%hacer el cluster con k-means (BoF)
[~,A]=vl_kmeans(d,TC);

%bucle para calcular cuantas caracteristicas hay por centroide
 F=zeros(1,TC);%vector de 0, cuantas caracteristicas por word hay en la imagen 
    
    for j=1:length(A)
      p=A(j);
      F(p)=F(p)+1;
    end
    tot=sum(F);
    for j=1:TC
     F(j)=F(j)/tot;
    end
%añadir el vector a una lista de vectores por clase
claseact=trainset{1,i}.classe;
  switch claseact
      case 'concert'
         for j=1:TC
          concert(cn1,j)=F(j);
          event(cn10,j)=F(j);
         end
         cn1=cn1+1;
         cn10=cn10+1;
      case 'conference'
          for j=1:TC
          conference(cn2,j)=F(j);
          event(cn10,j)=F(j);
          end
         cn2=cn2+1;
         cn10=cn10+1;
      case 'exhibition'
          for j=1:TC
          exhibition(cn3,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn3=cn3+1;
          cn10=cn10+1;
      case 'fashion'
          for j=1:TC
          fashion(cn4,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn4=cn4+1;
          cn10=cn10+1;
      case 'protest'
          for j=1:TC
          protest(cn5,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn5=cn5+1;
          cn10=cn10+1;
      case 'sports'
          for j=1:TC
          sport(cn6,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn6=cn6+1;
          cn10=cn10+1;
      case 'non_event'
         
          for j=1:TC
          non_event(cn7,j)=F(j);
          end
          cn7=cn7+1;
         
      case 'other'
          for j=1:TC
          other(cn8,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn8=cn8+1;
          cn10=cn10+1;
      case 'theater_dance'
          for j=1:TC
          dante(cn9,j)=F(j);
          event(cn10,j)=F(j);
          end
          cn9=cn9+1;
          cn10=cn10+1;
   end   
% end
%normalizar los valores
end

% calcular un arbol kdtree para cada clase
KDTree_concert=createns(concert,'NSMethod','kdtree','Distance','cityblock');
KDTree_conference=createns(conference,'NSMethod','kdtree','Distance','cityblock');
KDTree_exhibition=createns(exhibition,'NSMethod','kdtree','Distance','cityblock');
KDTree_fashion=createns(fashion,'NSMethod','kdtree','Distance','cityblock');
KDTree_protest=createns(protest,'NSMethod','kdtree','Distance','cityblock');
KDTree_sport=createns(sport,'NSMethod','kdtree','Distance','cityblock');
KDTree_non_event=createns(non_event,'NSMethod','kdtree','Distance','cityblock');
KDTree_other=createns(other,'NSMethod','kdtree','Distance','cityblock');
KDTree_dante=createns(dante,'NSMethod','kdtree','Distance','cityblock');
KDTree_event=createns(event,'NSMethod','kdtree','Distance','cityblock');

clear trainset; %eliminar el trainset
save (kdtreename,'-v7.3'); %guardar modelos entrenados