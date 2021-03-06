%--------------- Voice Recognition with Voice
clear
% Import Signal Processing Add On

%---------------Importing Dataset
%https://www.kaggle.com/primaryobjects/voicegender
voicedata = readtable('voice.csv');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%VOICE PART%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %---------------Read Test Voice
% [audioIn,Fs] = audioread('sample.m4a');
% 
% %Play audio
% % sound(audioIn,Fs);
% 
% timeVector = (1/Fs) * (0:size(audioIn,1)-1);
% figure
% plot(timeVector,audioIn) 
% ylabel("Amplitude")
% xlabel("Time (s)")
% title("Sample Audio")
% grid on
% 
% % Detect speech
% %speechIndices = detectSpeech(audioIn,Fs);
% 
% % Freq
% freq = meanfreq(audioIn);
% med = median(audioIn);
% mod = mode(audioIn);
% stddev = std(audioIn);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% meanfreq: mean frequency (in kHz)
% sd: standard deviation of frequency
% median: median frequency (in kHz)
% mode: mode frequency

%---------------Check for missing values
missings = sum(ismissing(voicedata));

%---------------Classification with mean frequency, median value and mode value.
classification_model = fitctree(voicedata, 'label~meanfreq+median+mode+sd'); %Classification Model

%--------------- Loop for calculating average accuracy
general_accuracy = 0;

for a = 1:10
   %---------------Partitioning
   cv = cvpartition(classification_model.NumObservations,'HoldOut', 0.03); %Built-in function for partitioning
   cross_validated_model = crossval(classification_model, 'cvpartition', cv); %Use training part of training set only to built model 
    
   %---------------Prediction
   Predictions = predict(cross_validated_model.Trained{1}, voicedata(test(cv),1:end-1));
   
   %---------------Analyzing the result
   %Confusion Matrix: / diagonal will give the false predictions, \ will be the rigth predictions.
   Results = confusionmat(cross_validated_model.Y(test(cv)),Predictions); 
   
   % coloredResultsMatrix = confusionchart(Results,'DiagonalColor','green');
   right_results = Results(1,1) + Results(2,2);
   wrong_results = Results(1,2) + Results(2,1);
   truth_score = right_results /(right_results + wrong_results);
   
   %Sum each accuracy to calculate general_accuracy outside the loop
   general_accuracy = general_accuracy + truth_score;
    
end
general_accuracy = general_accuracy / a; 
%Print general accuracy 
disp('General accuracy is:');
disp(general_accuracy);