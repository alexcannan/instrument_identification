for i = 1:size(trainingData,1)
    temp = zeros(3,size(trainingData{i},2));
    temp = trainingData{i}{1:3,size(temp,2)};
    trainingData{i} = temp;
end