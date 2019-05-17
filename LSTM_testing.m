% Assume network is already trained and has variable name "net"

length = size(testingData,2);
Yresults = categorical(zeros(1,length));
Ycompare = zeros(1,length);
testingClass = categorical(testingClass);
for i = 1:length
    Yresults(i) = classify(net,testingData(i));
    if Yresults(i) == testingClass(i)
        Ycompare(i) = 1;
    end
end
SuccessRate = sum(Ycompare)/length;
disp(strcat("Success rate = ",num2str(SuccessRate)))