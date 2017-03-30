function [data, label]=ExtractTrials(arch, opt)
%--------------------------------------------------------------------------
%Extract EEG trials from the data that have been converted from ov to mat. 

%outpus:
%data: a M x N x C matrix, where M is the number of observations (trials,
%epochs), N is the number of samples and C is the number of channels. 
%label: a M x 1 vector containing class labels. 1=target class, 2=non-target
%class. 

%inputs:
%arch: string. Name (if needed, with the direction) of the archive where the
%data in mat format is located. 
%opt: struct containing the options for the pre-processing steps. 
%If opt is empty or is not given then the default options are used:

%opt.filt.make=1; 1=do Butterworth filter, 0=do not filter, raw data
%opt.filt.cof=[0.1 12]; low and high cutoff frequencies
%opt.filt.order=2; order of the desired filter 
%(the final filter order is twice the opt.filt.order see 'help butter'). 
%opt.norm=0; 1=zscore normalization and windzoring, 0=raw data
%opt.window=1; Duration Time in seconds of the EEG trials
%(they are extrated from the begining of the intecification). 
%opt.downsamp=1; 1=no downsampling. It have to be any divider of sampleFreq.



%Victoria Peterson
%March 2017 . 
%--------------------------------------------------------------------------
if nargin <2 || isempty(opt)
    opt.filt.make=1; 
    opt.filt.cof=[0.1 12];
    opt.filt.order=2;
    opt.norm=0; 
    opt.window=1; 
    opt.downsamp=1;
end

load(arch)


CantChannels=size(samples,2);

%---------Filtrado---------------
%pass-band forward-backward Butterworth filter 
signals=zeros(size(samples));
if opt.filt.make==1
    if length(opt.filt.cof)~=2
        error('the cut off frequency have to be a 2x1 vector')
    else
        [b,a] = butter(opt.filt.order, [opt.filt.cof(1) opt.filt.cof(2)]/(samplingFreq/2), 'bandpass');
        for c=1:CantChannels
        signals(:,c)=filtfilt(b, a, samples(:,c));
        end
    end

end   

%----Normalization
if opt.norm==1
    signals=zscore(signals); %raw norm
    signals=winsoring(signals, 95);
end

%----Epoching

target_ind=stims(:,2)==33285;
nontarget_ind=stims(:,2)==33286;
ind=logical(target_ind+nontarget_ind);
CantTrials=sum(ind);

startIdx = floor(stims(ind,1) * samplingFreq) + 1;
stopIdx = startIdx + floor(opt.window * samplingFreq) - 1;


label=double(ind);
label(nontarget_ind)=2;
label(target_ind)=1;
label=label(label~=0);

for i=1:CantTrials
    epoch=signals(startIdx(i):stopIdx(i),:);

    %-----Downsampling----
    if opt.downsamp~=1
        if mod(samplingFreq, opt.downsamp) ~=0
            error('Decimation factor need to be a factor of the samplig frequency');
        end
        aux=downsample(epoch(:), opt.downsamp);
        epoch=reshape(aux, (vf-vi)/opt.downsamp,CantChannels); 
        data(i,:,:)=epoch;
    else
        data(i,:,:)=epoch;
    end
   
end