clear all ;
child=get(0,'children');
for ind=1:numel(child); close(child(ind));end ;

fprintf('Y.BELABID \n');

load('area.mat');
load('Cortex11.mat');

%% Surface of each element

F = Faces ;
V = Vertices ;
for i=1:size(F,1)
P1=V(F(i, 1), :);
P2=V(F(i, 2), :);
P3=V(F(i, 3), :);
face_area(i) = 1/2*norm(cross((P2-P1),(P3-P1)));
test_Surf(i) =  s(i)- face_area(i) ;
end
face_area = face_area';
test_Surf = test_Surf';
sum_face = sum(face_area); 

%% Mean Areas for Nodes
for M=1:size(V,1)
    [i,l]=find(F==M);
    Surf_moyenne(M)=(1/3)*sum(face_area(i));
end
Surf_moyenne=Surf_moyenne';
sum_face3 = sum(Surf_moyenne);

%% PHI(nodes) ==> PHI(elements)

load('traceelement.mat');
load('tracePHI.mat');
N = detPHI;
F = Faces ;

for i=1:size(F,1)
P4=N(F(i, 1), 1);
P5=N(F(i, 2), 1);
P6=N(F(i, 3), 1);
PHI_elem(i) = (1/3)*(P4+P5+P6);

test(i) =  u(i) - PHI_elem(i) ;
end

PHI_elem = PHI_elem';
test = test';

%% Matlab data ==> .VTK

%edata = PHI_elem./face_area ; 
edata = N./Surf_moyenne ; 
nodes = Vertices;
elements = Faces;
filename = 'cortexw.vtk';
fileID = fopen(filename,'w');
if fileID == -1
    disp(['impossible de trouver ce fichier',filename])
end

fprintf(fileID,'# vtk DataFile Version 3.0\n');
fprintf(fileID,'Maillage en elements trangulaires - Y.BELABID \n');
fprintf(fileID,'ASCII\n');
fprintf(fileID,'DATASET UNSTRUCTURED_GRID\n'); 
fprintf(fileID,'POINTS %d float\n',size(nodes,1));
fprintf(fileID,'%30.20f %30.20f %30.20f\n',nodes');
fprintf(fileID,'\n');
fprintf(fileID,'CELLS %d %d\n',size(elements,1),4*size(elements,1));
fprintf(fileID,'3 %d %d %d\n',elements(:,1:3)'-1);
fprintf(fileID,'\n');
fprintf(fileID,'CELL_TYPES %d\n',size(elements,1));
fprintf(fileID,'%d\n',5*ones(size(elements,1),1));

% element type 
% if we choose to display edata = N./Surf_moyenne, we must choose the nodes
% instead of elements (POINT_DATA)
% if we choose to display edata = PHI_elem./face_area, we must choose the elements instead of nodes (CELL_DATA) 

if (size(edata,1) ~= size(nodes,1)) % (size(edata,1) ~= size(nodes,1))
    error('Error: check edata size ! ');    
end

fprintf(fileID,'POINT_DATA %d\n',size(edata,1)); % fprintf(fileID,'POINT_DATA %d\n',size(edata,1));
fprintf(fileID,'SCALARS edata float\n');
fprintf(fileID,'LOOKUP_TABLE default\n');
fprintf(fileID,'%10.12f\n',edata);
fprintf(fileID,'\n');

%fprintf(fileID,'# vtk DataFile Version 3.0\n');
%

fclose('all');

