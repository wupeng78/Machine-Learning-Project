function createDbFiles(filename, suppix_offset, for_training)
%data_path = 'E:\dropbox\documents\course_work\fall12_10701\course_project\label_propogation\forAlchemy';

%Printing Adjacency data in the form of IsNeighbor predicates
img1_adj13=dlmread([filename '.adj13.csv']);
fileID = fopen([filename '.neighbor.db'],'w');
for i=1:size(img1_adj13,1)
    for j=1:size(img1_adj13,2)
        if(img1_adj13(i,j) == 1)
            fprintf(fileID,'IsNeighbor(%d,%d)\n', suppix_offset + i,...
                suppix_offset + j);
        end
    end
end
fclose(fileID);

%Printing ground truth data in the form of IsLabel predicates
if(for_training)
    fileID = fopen([filename '.labels.db'],'w');
    superpix_GT = load([filename '.GT.mat'], 'ground_truth_labels');
    for i=1:size(suppix_GT,1)
        fprintf(fileID, 'IsLabel(%d,%d)\n', suppix_offset + i, superpix_GT(i));
    end
    fclose(fileID);
end
%Printing feature information in the form of FeatureDistance predicates
fileID = fopen([filename '.features.db'],'w');
features = dlmread([filename '.features.csv']);
for i=1:size(features,1)
    for j=1:size(features,2)
        for k=1:size(features,2)
            fprintf(fileID, 'FeatureDistance(%d,%d,%d) %f\n', j,k,i,...
                -(features(i,j) - features(i,k))^2);
        end
    end
end
fclose(fileID);
end