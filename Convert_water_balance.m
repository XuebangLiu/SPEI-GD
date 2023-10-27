%% Convert water balance in “.mat” format to “.nc” for easy processing of R programming Language 
clc; clear all;
str1=' \ERA5_Singer\Year\';
str2=' \ERA5_Singer\NC_ZH\';
for i= 1983:2021
    tem1=[]; tem2=[]; Water_Deficit=[];
    load([str1,num2str(i-1),'.mat'])
    tem1=Water_Balance;
    Water_Balance=[];
    load([str1,num2str(i),'.mat'])
    tem2=Water_Balance;
    Water_Balance=[];
    Water_Deficit=cat(3,tem1,tem2);
    [a,b,c]=size(Water_Deficit);
    nccreate([str2,num2str(i),'.nc'],'Water_Deficit','Dimensions', {'x',a,'y',b,'z',c},'FillValue','disable');
    ncwrite([str2,num2str(i),'.nc'],'Water_Deficit',Water_Deficit);
end
