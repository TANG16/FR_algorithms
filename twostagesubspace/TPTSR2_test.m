function TPTSR2_test(A)
%adding centre of a class as a new sample to facilitate the seletion of the
%number of neighbors.

% two stage test sample sparse representation test



M=10:10:200;
test_M=size(M,2);
test_num=252; %experiment times
res_correct_rate=zeros(test_num,test_M);
correct_number_recorder_M=zeros(1,test_M);% correct_rate against M in one test
final_result=zeros(2,test_M);% mean and variance in column
class_num=40;
sample_num=10;
mu=0.01;       
train_num=5;         %samples used for trainning in each class
test_sample_num=5;   %samples used in tests in each class
[n_A, m_A]=size(A);
 test_table1=combntns(1:10,5);
for test=1:test_num
    disp(['test number=  ',num2str(test)])
    cputime_start=cputime;
    %to set matrix train_A train samples
    % and matrix test_A test samples
    tmp_index_test=zeros(1,test_sample_num*class_num);
    tmp_index_train=zeros(1,train_num*class_num);
    
    %method 1 randomly pick test samples
    %     for tmp_i=1:class_num
    %         tmp=randperm(sample_num);
    %         tmp_index_test(1+(tmp_i-1)*test_sample_num:tmp_i*test_sample_num)=tmp(1:test_sample_num)+(tmp_i-1)*sample_num;
    %         tmp_index_train(1+(tmp_i-1)*train_num:tmp_i*train_num)=tmp(test_sample_num+1:sample_num)+(tmp_i-1)*sample_num;
    %     end
    %   method 2 pick the test sample manually
    train_sample_index= test_table1( test,:);%[1,3,5,7,9,11,13,15];%1:5;
    train_num=size(train_sample_index,2);%samples used for trainning in each class
    test_sample_index=test_table1( 252+1-test,:);%[2,4,6,8,10,12,14];%6:10;
    test_sample_num=size(test_sample_index,2);%samples used in tests in each class
    for tmp_i=1:class_num
        tmp_index_test(1+(tmp_i-1)*test_sample_num:tmp_i*test_sample_num)= test_sample_index+(tmp_i-1)*sample_num;
        tmp_index_train(1+(tmp_i-1)*train_num:tmp_i*train_num)=train_sample_index+(tmp_i-1)*sample_num;
    end
    %method 3 "leave-one-out"
    %      tmp_index_test=test:sample_num:class_num*sample_num;
    %    tmp_index_train=setxor([1:class_num*sample_num], tmp_index_test) ;
    %====================================
    train_A=A( tmp_index_train,:) ;
    test_A=A( tmp_index_test,:) ;
    %===========================
    num_of_test_sample=test_sample_num*class_num;
    %query image testing
    train_A_new=zeros(class_num*train_num+class_num,m_A);
    for test_sample_No=1:num_of_test_sample
        
        test_sample=test_A(test_sample_No,1:(m_A-1))';
        %creat a index vector indicating the distance between test sample and all the gallery images 
        [ index_all ] =m_neighbors( train_A, test_sample', 200);

        alfa=inv(train_A(:,1:(m_A-1))*train_A(:,1:(m_A-1))'+mu*eye(class_num*train_num))*train_A(:,1:(m_A-1))*test_sample;
        alfa_new=zeros(1,num_of_test_sample+class_num);
        %creat new sample using centres 0f classes
        for i=1:class_num
            class_centre=[alfa((i-1)*train_num+1:i*train_num)'*train_A((i-1)*train_num+1:i*train_num,1:(m_A-1)),i];
            train_A_new((i-1)*(train_num+1)+1:i*(train_num+1),:)=[train_A((i-1)*train_num+1:i*train_num,:);class_centre];
            alfa_new((i-1)*(train_num+1)+1:i*(train_num+1))=[alfa((i-1)*train_num+1:i*train_num,:)',1];
        end
        
        res=zeros(1,num_of_test_sample+class_num);
        for i=1:num_of_test_sample+class_num
            res(i)=norm(test_sample'-alfa_new(i)*train_A_new(i,1:(m_A-1))) ;
        end           
        clear alfa alfa_new
        [sort_res,index_all]=sortrows(res');
        for difference_M=1:test_M
            current_M=M(difference_M);
            index=index_all(1:current_M);
            index=sort(index);
            train_A_sec=train_A_new(index,:);
            [class_index,first_label]=unique(train_A_sec(:,m_A)','first');
            [class_index,last_label] =unique(train_A_sec(:,m_A)','last');
            class_num_sec=size(class_index,2);
            
            alfa=inv(train_A_sec(:,1:(m_A-1))*train_A_sec(:,1:(m_A-1))'+mu*eye(current_M))*train_A_sec(:,1:(m_A-1))*test_sample;
            residual=zeros(1,class_num_sec);
            for i=1:class_num_sec
                index_class_i=first_label(i):last_label(i);
                residual(i)=norm(test_sample-train_A_sec(index_class_i,1:(m_A-1))'*alfa(index_class_i));
            end
            [min_res,index_min_res]=min(residual);
            d1=class_index(index_min_res);
            correct_number_recorder_M(difference_M)=correct_number_recorder_M(difference_M)+(d1==test_A(test_sample_No,m_A));
        end
        
    end
    correct_number_recorder_M=correct_number_recorder_M/num_of_test_sample; 
    res_correct_rate(test,:)=correct_number_recorder_M;  
    correct_number_recorder_M=zeros(1,test_M);
    disp(['cputime',num2str(cputime-cputime_start)])
end

for i=1:test_M
   final_result(1,i)= mean(res_correct_rate(:,i));
   final_result(2,i)= std(res_correct_rate(:,i));
end



