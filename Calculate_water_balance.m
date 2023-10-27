%%% Calculate water balance
clc; clear all;
str1=' \precipitation\Mat\';
str2=' \Singer_PET\Mat\';
str3=' \ERA5_Singer\Year\';
for i= 1982:2021
    load([str1,num2str(i),'.mat'])
    load([str2,num2str(i),'.mat'])
    Water_Balance=PRE*1000-PET;
    save([str3,num2str(i),'.mat'],'Water_Balance')
end
