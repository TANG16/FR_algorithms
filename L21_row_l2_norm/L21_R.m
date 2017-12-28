function [ rate ] = L21_R( train_data,test_data,row,col)
% L21 ��������е���ʽ��L2����
%

[~,n] = size(train_data);
class = unique(train_data(:,n));%��
clas_tra = train_data(:,n);     %ѵ�����ǩ
clas_tes = test_data(:,n);      %�������ǩ
A_cell = cell(1,size(class,1)); %A_cell{i} ָsubjecti����ѵ������

for k = 1:size(class,1)
    ind2 = (clas_tra == class(k));
    trak = train_data(ind2,:);
    A = cat(3,reshape(trak(1,1:n-1),row,col),reshape(trak(2,1:n-1),row,col));
    for it = 3:size(trak)
        A = cat(3,A,reshape(trak(3,1:n-1),row,col));
    end
    A_cell{k} = A;
end
right = 0;

for i = 1:size(class,1)
    ind = (clas_tes==class(i));
    tesi = test_data(ind,:);                    %��i���Y
    class(i)
    for j = 1:size(tesi,1)
        Y = reshape(tesi(j,1:n - 1),row,col);   %��i��ĵ�j��Y
        DIS = zeros(size(class,1),1); 
        for k = 1:size(class,1)
            A = A_cell{k};                                          
            [X,Wl] = train(A,Y,row);            %����           
            DIS(k) = Get_dis_row(X,A,Y);
        end
        [~,no] = min(DIS);
        if class(no) == class(i)
            right = right+1;
        end
    end    
end
rate = right /size(test_data,1);
end


function [X,Wl] = train(A,Y,row)
Wl = zeros(1,row) + 1/row;
[~,~,N] = size(A);
T = ones(N,1)*inf;
X = zeros(N,1);
i = 1;
while norm(T-X)>0.0001||i<11 
    i = i +1;
    T = X;
    X = Get_x_row(A,Y,Wl);
    [Wl] = Get_w_row(A,Y,X');
end
end

