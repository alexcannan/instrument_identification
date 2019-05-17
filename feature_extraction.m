% Takes in file variable, fills frameData array with selected features

[y,Fs] = audioread(file);

numFeatures = 42;

%Split into frames
%TODO: Overlap/Windowing?
buffPeriod = 20; %ms
frameSamps = Fs*(buffPeriod*0.001);
numFrames = floor(size(y,1)/frameSamps);
frameData = zeros(numFeatures,numFrames);

% MFCC Data [4-16 MFCC, 17-29 dMFCC, 30-42 ddMFCC]
[coeffs,delta,deltaDelta,loc] = mfcc(y,Fs,'WindowLength',frameSamps,'OverlapLength',0,'LogEnergy','Ignore');
frameData(4:16,:) = coeffs.';
frameData(17:29,:) = delta.';
frameData(30:42,:) = deltaDelta.';

%Fundamental Frequency [1]
fundFreq = median(pitch(y,Fs));
%'WindowLength',frameSamps,'OverlapLength',0
frameData(1,:) = fundFreq;

for b = 0:numFrames-1
    frame = y((b*frameSamps+1):((b+1)*frameSamps));
    frame = frame.*hamming(frameSamps);
    
    %Normalized Centroid Data [2-3] (mean and stddev)
    freqData = abs(fft(frame));
    freqData = freqData(1:size(freqData,1)/2);
    freqScale = 0:Fs/size(freqData,1):Fs*(1-1/size(freqData,1));
    meanCentr = sum(freqScale.'.*freqData)/sum(freqData);
    stdData = (freqScale-meanCentr).^2;
    stdCentr = sqrt(sum(freqScale.*stdData)/sum(stdData));
    if isnan(meanCentr)
        frameData(2,b+1) = 0;
    else
        frameData(2,b+1) = meanCentr/fundFreq;
    end
    if isnan(stdCentr)
        frameData(3,b+1) = 0;
    else
        frameData(3,b+1) = stdCentr/fundFreq;
    end
end