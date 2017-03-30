clear all
close all
clc

addpath(genpath('ov2mat'))
%% convert OV to MAT
archivo='p300-train.ov';
salida='p300-train-convert.mat';
convert_ov2mat(archivo, salida)

%% ExtractTrials
archivo='p300-train-convert.mat';
[data, label]=ExtractTrials(archivo);

target=data(label==1,:,:);
nontarget=data(label==2,:,:);

%% plot great average
subplot(1,2,1), imagesc(reshape(mean(target), 512, 16)'); title('target')
subplot(1,2,2),imagesc(reshape(mean(nontarget), 512, 16)'); title('non target')
