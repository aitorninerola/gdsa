%entreno clasificador visual
%cargamos los datos
load('train_vdes');%variabe en formato .mat
%mirar el tamaño de los datos (cuantas fotos son)
numim=length(trainset);
%buscamos el valor minimo de caracteristicas para el cluster y establecer
%el valor de TC

tam=size(trainset{1,1}.caracteristiques);
min=tam(2);
for i=2:length(trainset)
 tamact=size(trainset{1,i}.caracteristiques);
 minact=tamact(2);
 if minact<min
   min=minact;
   t=i;
 end
end
TC=min; %numero de clusters/words en que se hara la particion de caracteristicas
%contadores para reyenar las matrices con las caracteristicas de todas las
%imagenes de entreno
cn1=1;cn2=1;cn3=1;cn4=1;cn5=1;cn6=1;cn7=1;cn8=1;cn9=1;
AP=zeros(1,TC);%para calcular IDF DF
for i=1:numim
%conseguir la caracteristica de la imagen que se esta leyendo
d=trainset{1,i}.caracteristiques;
%convertirlas al formato single
d=single(d);
%hacer el cluster con k-means (BoF)
[C,A]=vl_kmeans(d,TC);

%bucle para calcular cuantas caracteristicas hay por centroide
 F=zeros(1,TC);%vector de 0, cuantas caracteristicas por word hay en la imagen TF
 %F es el TF para calcular el TF-IDF   
    for j=1:length(A)
      p=A(j);
      F(p)=F(p)+1;
    end
    for j=1:TC
      if F(j)~=0
        AP(j)=AP(j)+1;% aparicion de un cluster en el documento  
      end
    end
   
%añadir el vector a una lista de vectores por clase
claseact=trainset{1,i}.classe;
  switch claseact
      case 'concert'
         for j=1:TC
          concert(cn1,j)=F(j);
         end
         cn1=cn1+1;
      case 'conference'
          for j=1:TC
          conference(cn2,j)=F(j);
          end
         cn2=cn2+1;
      case 'exhibition'
          for j=1:TC
          exhibition(cn3,j)=F(j);
          end
          cn3=cn3+1;
      case 'fashion'
          for j=1:TC
          fashion(cn4,j)=F(j);
          end
          cn4=cn4+1;
      case 'protest'
          for j=1:TC
          protest(cn5,j)=F(j);
          end
          cn5=cn5+1;
      case 'sports'
          for j=1:TC
          sport(cn6,j)=F(j);
          end
          cn6=cn6+1;
      case 'non_event'
          for j=1:TC
          non_event(cn7,j)=F(j);
          end
          cn7=cn7+1;
      case 'other'
          for j=1:TC
          other(cn8,j)=F(j);
          end
          cn8=cn8+1;
      case 'theater_dance'
          for j=1:TC
          dante(cn9,j)=F(j);
          end
          cn9=cn9+1;
   end   
end
%se ha calculado el TF de cada documento y el DF de la coleccion
%calcularemos el IDF
IDF=zeros(1,TC);
for i=1:TC
    IDF(i)=log10(1+(numim/AP(i)));
end
%calcular el TF-IDF para cada clase

for i=1:TC
  TFIDF(1,i)=sum(concert(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(2,i)=sum(conference(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(3,i)=sum(exhibition(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(4,i)=sum(fashion(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(5,i)=sum(protest(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(6,i)=sum(sport(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(7,i)=sum(non_event(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(8,i)=sum(other(:,i))*IDF(i);
end
for i=1:TC
  TFIDF(9,i)=sum(dante(:,i))*IDF(i);
end

%bucle para normalizar el vector de TFIDFs (que la suma sea 1)
 for i=1:9  
   tot=sum(TFIDF(i,:));
   for j=1:TC
    TFIDFn(i,j)=TFIDF(i,j)/tot;
   end
 end
 