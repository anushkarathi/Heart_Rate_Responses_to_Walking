path_directory='/Users/anushkarathi/Desktop/participantdata/s1'; %directory of where data is located
exercisefiles=dir([path_directory '/*.xlsx']); %importing all of the collected data from in-lab part of experiment
exercisefiles=struct2cell(exercisefiles);
SpeedNStdev=dir([path_directory '/*.mat']); %importing all of the collected data from in-lab part of experiment
SpeedNStdev=struct2cell(SpeedNStdev);

%gets only the file names from all of the imported data 
filename=exercisefiles(1,:); 
speed=SpeedNStdev(1,:); 
 
%sorts the file names into treadmill, overground, quiet standing data, treadmill speed and stdev, and overground speed and stdev 
treadmill = regexp(filename, '.*speed.*', 'match'); 
treadmill=treadmill(~cellfun('isempty',treadmill));

overground = regexp(filename, '.*bpm.*', 'match');
overground= overground(~cellfun('isempty',overground));

standing = regexp(filename, '.*quiet.*', 'match');
standing = standing(~cellfun('isempty', standing));

speedtreadmill= regexp(speed, '.*R.*', 'match'); 
speedtreadmill=speedtreadmill(~cellfun('isempty', speedtreadmill)); 

speedoverground= regexp(speed, '.*imu.*', 'match'); 
speedoverground= speedoverground(~cellfun('isempty', speedoverground)); 

%loading the standing file into cell entry and identify the start time of the recording
datastandingST=readtable(char(standing{1}),'Format', 'auto');
start_time_standing = timeofday(datetime(char(table2cell(datastandingST(1,5))))); 

%finding duration time of the standing data
StandingDuration=readtable(char(standing{1}),'ReadVariableNames', true);
standingtime = timeofday(datetime(StandingDuration.t,'ConvertFrom','excel')); 
end_time_standing=standingtime(end)+start_time_standing; 

%loading the treadmill and overground files into cell entries and identify the start time of the recording
for i=1:length(treadmill)
    datatreadmillST{i}=readtable(char(treadmill{i}),'Format', 'auto');
    start_time_treadmill{i}=char(table2cell(datatreadmillST{i}(1,5))); 
    start_time_treadmill{i}=timeofday(datetime(start_time_treadmill{1,i})); 
end

for i=1:length(overground)
    dataovergroundST{i}=readtable(char(overground{i}),'Format', 'auto', 'ReadVariableNames', true);
    start_time_overground{i}=char(table2cell(dataovergroundST{i}(1,5)));
    start_time_overground{i}=timeofday(datetime(start_time_overground{1,i})); 
    
end

%finding duration time of the treadmill data 
treadmilltime={};
overgroundtime={};

for i=1:length(treadmill)
TreadmillDuration{i}=readtable(char(treadmill{i}),'ReadVariableNames', true);
treadmilltime{i} = timeofday(datetime(TreadmillDuration{i}.t,'ConvertFrom','excel'));
end_time_treadmill{i}=(treadmilltime{i}(end))+start_time_treadmill{i}; 
end 

for i=1:length(overground)
OvergroundDuration{i}=readtable(char(overground{i}),'ReadVariableNames', true);
overgroundtime{i} = timeofday(datetime(OvergroundDuration{i}.t,'ConvertFrom','excel'));
end_time_overground{i}=(overgroundtime{i}(end))+start_time_overground{i}; 
end

%loading heart rate files 
HRfiles=dir([path_directory '/*.csv']); %importing the HR data 
start_time_HR= timeofday(datetime(HRfiles.name(27:end-4), 'InputFormat', 'HH-mm-ss'));
stotal= readtable(HRfiles.name);
stotal=stotal(:,[2,3]); %table storing the time and the HR values
HR_time=table2cell(stotal(:,1));

%saving the HR data with the time stamp in stotal 
HRovertime={};
for j=1:length(HR_time)
   HRovertime{j,1}=start_time_HR+HR_time{j,1};
end 
stotal(:,1)=cell2table(HRovertime);
stotalTime=table2timetable(stotal); %make this into a timetable so we can traverse through the data with time 

%saving all HR of overground by sorting
OVERGROUND={};
for i=1:length(end_time_overground)
    last_two_overground=end_time_overground{i}-minutes(2); 
%     TRO=timerange(start_time_overground{i}, end_time_overground{i});
    TRO=timerange(last_two_overground, end_time_overground{i});
    overg=stotalTime(TRO,:);
    overg=timetable2table(overg);
    OVERGROUND{i}=table2cell(overg(:,2)); 
    avgoverground(i)=mean(cell2mat(OVERGROUND{i}));
    stdevoverground(i)=std(cell2mat(OVERGROUND{i}));
    
end 

%saving all HR of treadmill by sorting 
TREADMILL={};
for i=1:length(end_time_treadmill)
    last_two_treadmill=end_time_treadmill{i}-minutes(2); 
%     TRT=timerange(start_time_treadmill{i}, end_time_treadmill{i});
    TRT=timerange(last_two_treadmill, end_time_treadmill{i});
    treadm=stotalTime(TRT,:);
    treadm=timetable2table(treadm);
    TREADMILL{i}=table2cell(treadm(:,2));
    avgtreadmill(i)=mean(cell2mat(TREADMILL{i}));
    stdevtreadmill(i)=std(cell2mat(TREADMILL{i}));
end 

%average of the treadmill data and std 
 nameavgspeedt=char(speedtreadmill{1}); 
 TS=load(nameavgspeedt, '-mat');
 TS=struct2array(TS); 
 namestdt=char(speedtreadmill{2}); 
 TSTD=load(namestdt, '-mat'); 
 TSTD=struct2array(TSTD);

 %average of the overground data and std 
 nameavgo=char(speedoverground{1}); 
 OS=load(nameavgo, '-mat'); 
 OS=struct2array(OS); 
 namestdo=char(speedoverground{2}); 
 OSTD=load(namestdo, '-mat'); 
 OSTD=struct2array(OSTD);

 %plots the average HR during both treadmill and overground trials with average stride speed during these trials 
figure 
errorbar(TS,avgtreadmill, stdevtreadmill,stdevtreadmill, TSTD, TSTD, 'kx', 'Linewidth', 3); 
hold on
errorbar(OS,avgoverground, stdevoverground,stdevoverground, OSTD, OSTD, 'rx', 'Linewidth', 3); 
xlabel('Speed (m/s)');
ylabel('Average HR');
legend('Treadmill', 'Overground');
title('Average HR per Speed');
set(gca, 'FontSize', 15,'Fontweight', 'bold'); 
xlim([0.6 1.9])
grid on

%plots all of the HR data collected in lab and sections based off of speed/bpm
figure 
b=timeofday(datetime((char(string(HRovertime)))));
a=cell2mat(table2cell(stotal(:,2)));
plot(b,a, 'Linewidth', 1.5)
hold on 
xline(start_time_treadmill{1}, 'k', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{1}, 'k', 'Linewidth', 2)
hold on 
xline(start_time_treadmill{2}, 'r', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{2}, 'r', 'Linewidth', 2)
hold on 
xline(start_time_treadmill{3}, 'g', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{3}, 'g', 'Linewidth', 2)
hold on 
xline(start_time_treadmill{4}, 'b', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{4}, 'b', 'Linewidth', 2)
hold on 
xline(start_time_treadmill{5}, 'y', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{5}, 'y', 'Linewidth', 2)
hold on 
xline(start_time_treadmill{6}, 'c', 'Linewidth', 2)
hold on 
xline(end_time_treadmill{6}, 'c', 'Linewidth', 2)
hold on 
xline(start_time_overground{1}, 'k', 'Linewidth', 2)
hold on 
xline(end_time_overground{1}, 'k', 'Linewidth', 2)
hold on 
xline(start_time_overground{2}, 'r', 'Linewidth', 2)
hold on 
xline(end_time_overground{2}, 'r', 'Linewidth', 2)
hold on 
xline(start_time_overground{3}, 'g', 'Linewidth', 2)
hold on 
xline(end_time_overground{3}, 'g', 'Linewidth', 2)
hold on 
xline(start_time_overground{4}, 'b', 'Linewidth', 2)
hold on 
xline(end_time_overground{4}, 'b', 'Linewidth', 2)
hold on 
xline(start_time_overground{5}, 'y', 'Linewidth', 2)
hold on 
xline(end_time_overground{5}, 'y', 'Linewidth', 2)
hold on 
xline(start_time_overground{6}, 'c', 'Linewidth', 2)
hold on 
xline(end_time_overground{6}, 'c', 'Linewidth', 2)
hold on 
xline(start_time_standing, 'c', 'Linewidth', 2)
hold on 
xline(end_time_standing, 'c', 'Linewidth', 2)
hold on 
