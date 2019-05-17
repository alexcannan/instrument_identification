% Takes in .json shortlist of training data, which contains filename and
% class data. This should be located at the directory specified by trainingPath.
% .json file has format: [[filename1,class1],[filename2,class2],...]

trainingPath = 'F:\Training Data\nsynth-train\'; %Path to NSynth training data
shortlist = jsondecode(fileread(strcat(trainingPath,'shortlist.json')));
numTrainers = size(shortlist,1);
trainingData = cell(numTrainers,1);
trainingClass = zeros(numTrainers,1);

for i = 1:numTrainers
    trainingClass(i) = shortlist{i}{2};
    file = strcat(trainingPath,'audio\',shortlist{i}{1},'.wav');
    feature_extraction
    trainingData{i} = frameData;
    disp(strcat('Processing File ',num2str(i),'/',num2str(numTrainers)))
end