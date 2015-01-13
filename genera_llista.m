% Copyright 2015 Aitor Niñerola
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
function varargout = genera_llista(varargin)
% Genera llista 
%
% Aquesta funció genera un llistat .txt amb el nom dels fitxers d'imatge
% d'una carpeta
%
%#genera_llista(dir) 
%   retorna una variable amb els resultats
%
%#genera_llista(dir, rule) 
%   retorna una variable amb els resultats
%   que coincideixin amb la regla establerta
%       Per exemple *.jpg llistarà només les imatges jpg
%
%#genera_llista(dir,rule,name)
%   Farà el mateix però desarà el fitxer amb el nom name.txt
%
% Aitor Niñerola - 2014

if nargin < 1
    error('Inclou la ruta al directori que vols llistar');
elseif nargin == 1
        files = dir(varargin{1});
        L = cell(length(files),1);
        for i = 1:length(files)
            [~,nom,~] = fileparts(files(i).name);
            L(i,1) = cellstr(nom);
        end
        varargout{1} = L;
        
elseif nargin == 2
    direc = strcat(varargin{1},varargin{2});
     files = dir(direc);
     L = cell(length(files),1);
        for i = 1:length(files)
            [~,nom,~] = fileparts(files(i).name);
            L(i,1) = cellstr(nom);
        end
        varargout{1} = L;
        
elseif nargin == 3
       direc = strcat(varargin{1},varargin{2});
    file = strcat(varargin{3},'.txt');
     files = dir(direc);
     L = cell(length(files),1);
        for i = 1:length(files)
            [~,nom,~] = fileparts(files(i).name);
            L(i,1) = cellstr(nom);
        end
        writetable(array2table(L),file, 'WriteVariableNames', false);
else
    error('Massa arguments d´entrada');
end

end