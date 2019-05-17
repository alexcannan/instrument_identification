inputFile = 'test_visualization\test_vis.wav';

[y,Fs] = audioread(inputFile);

measurementPeriod = 100; %ms, how often do we aggregate data and classify
windowSize = 4; %s, how much data to pull for classification
buffPeriod = 20; %ms, how small are the frames within each window

numFeatures = 42;

%Split into frames
frameSamps = Fs*(buffPeriod*0.001);
numFrames = floor(size(y,1)/frameSamps);
frameData = zeros(numFeatures,numFrames);

% MFCC Data [4-16 MFCC, 17-29 dMFCC, 30-42 ddMFCC]
[coeffs,delta,deltaDelta,loc] = mfcc(y,Fs,'WindowLength',frameSamps,'OverlapLength',0,'LogEnergy','Ignore');
frameData(4:16,:) = coeffs.';
frameData(17:29,:) = delta.';
frameData(30:42,:) = deltaDelta.';

%Fundamental Frequency [1]
fundFreqs = pitch(y,Fs,'Method','PEF','WindowLength',frameSamps,'OverlapLength',0);
frameData(1,:) = movmedian(fundFreqs,5);

for b = 0:numFrames-1
    frame = y((b*frameSamps+1):((b+1)*frameSamps));
    frame = frame.*hamming(frameSamps);
    
    fundFreq = frameData(1,b+1);
    
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

%Split into overlapping windows, fill visData cell vector
framePeriod = measurementPeriod/buffPeriod;
windowFrames = windowSize/buffPeriod/0.001;
numWindows = ((size(frameData,2)-(windowFrames))/(framePeriod));
visData = cell(numWindows,1);
for b = 1:numWindows
    tempWindow = frameData(:,(b-1)*framePeriod+1:(b-1)*framePeriod+windowFrames);
    visData{b} = tempWindow;
end

%Classify each cell, return probabilities into predVec
predVec = zeros(6,size(visData,1));
for b = 1:numWindows
    predVec(:,b) = predict(net,visData{b}).';
end