%beginning code (lines 2-22 courtesy of L.B.)
directory = uigetdir;
files = dir(directory + "/*.csv");
startdates_hrfiles = NaT(length(files),1);
datetime_hr = [];
hr_values = [];
i = 1;
for file = files'
    data = readtable(directory+"/"+string(file.name));
    year = string(file.name(16:19));
    month = string(file.name(21:22));
    day = string(file.name(24:25));
    hour = string(file.name(27:28));
    minute = string(file.name(30:31));
    second = string(file.name(33:34));
    datestring = year+'-'+month+'-'+day+' ' + hour + ':' + minute + ':' + second;
    startdates_hrfiles(i) = datetime(datestring);
    datetime_hr = [datetime_hr;data.Time+startdates_hrfiles(i)];
    hr_values = [hr_values;data.HR_bpm_];
end
allval=table(datetime_hr, hr_values); 
allval=table2timetable(allval);

matfiles=dir([directory '/*.mat']); %importing all of the collected data from in-lab part of experiment
matfiles=struct2cell(matfiles);
mfiles=matfiles(1,:);

start_stop_files=regexp(mfiles, '.*wp.*', 'match'); 
start_stop_files=start_stop_files(~cellfun('isempty', start_stop_files));

stride_files=regexp(mfiles,'.*grouped.*', 'match'); 
stride_files=stride_files(~cellfun('isempty', stride_files));

stride_files=char(stride_files{1});
stride_speed=load(stride_files, '-mat'); 

for i=1:length(start_stop_files)
    start_stop_times{i}=char(start_stop_files{i}); 
end 

timings={};
for i=1:length(start_stop_times)
    timings{i}=load(start_stop_times{i}, '-mat');
end

HR_walkingperiod={};
HRATE={}; 
for i=1:length(timings{2}.wp_startdate)
    TR=timerange(timings{2}.wp_startdate(i), timings{1}.wp_enddate(i));
    HR_walkingperiod{i}=allval(TR,:);
    HWP{i}=timetable2table(HR_walkingperiod{i}); 
    HWP{i}=rmmissing(HWP{i});
    HRATE{i}=table2cell(HWP{i}(:,2));
 
     if ((isempty(HRATE{i}))==0)
        end_half_HRATE{i}=HRATE{i}(end/2:end); 
        HRATE_mean(i)=mean(cell2mat(end_half_HRATE{i}));
        HRATE_stdev(i)=std(cell2mat(end_half_HRATE{i}));
    
    elseif ((isempty(HRATE{i}))==1)
        HRATE_mean(i)=0;
        HRATE_stdev(i)=0;
    end

    
end 

stride_speed_mean={};
stride_speed_stdev={}; 

for j=1:length(stride_speed.ss_all_grouped)
    stride_speed_mean{j}=mean(stride_speed.ss_all_grouped{j}); 
    stride_speed_stdev{j}=std(stride_speed.ss_all_grouped{j});
end

stride_speed_mean=cell2mat(stride_speed_mean);
stride_speed_stdev=cell2mat(stride_speed_stdev);

% plots the walk to/from work for May 30th for S1
figure 
plot(cell2mat(HRATE{64}), 'Linewidth',2); 
hold on 
plot(cell2mat(HRATE{67}), 'Linewidth',2); 
legend('walk to work','walk back from work')
xlabel('Time (sec)');
ylabel('Heart Rate');
title('S1 walk to/back work');
set(gca, 'FontSize',20, 'Fontweight','bold')

% plots the walk to/from compared to stride speed for May 30th for S1
figure
errorbar(stride_speed_mean(64),HRATE_mean(64),HRATE_stdev(64),HRATE_stdev(64),stride_speed_stdev(64),stride_speed_stdev(64),'r', 'Linewidth',2)
hold on
errorbar(stride_speed_mean(67),HRATE_mean(67),HRATE_stdev(67),HRATE_stdev(67),stride_speed_stdev(67),stride_speed_stdev(67),'k','Linewidth',2)
legend('walk to work','walk back from work')
xlabel('Stride Speed');
ylabel('Heart Rate');
title('S1 walk to/back work');
set(gca, 'FontSize',20, 'Fontweight','bold')

% plots the walks to work for May  26th, 27th, and  30th for S1
figure 
plot(cell2mat(HRATE{64}), 'Linewidth',2); 
hold on 
plot(cell2mat(HRATE{44}), 'Linewidth',2); 
hold on 
plot(cell2mat(HRATE{28}), 'Linewidth',2); 
legend('30th', '27th','26th'); 
xlabel('Time (sec)');
ylabel('Heart Rate');
title('S1 walk to work');
set(gca, 'FontSize',20, 'Fontweight','bold')

% plots the walks to work compared to stride speed for May  26th, 27th, and  30th for S1
figure
errorbar(stride_speed_mean(64),HRATE_mean(64),HRATE_stdev(64),HRATE_stdev(64),stride_speed_stdev(64),stride_speed_stdev(64),'r', 'Linewidth',2)
hold on
errorbar(stride_speed_mean(44),HRATE_mean(44),HRATE_stdev(44),HRATE_stdev(44),stride_speed_stdev(44),stride_speed_stdev(44),'r','Linewidth',2)
hold on
errorbar(stride_speed_mean(28),HRATE_mean(28),HRATE_stdev(28),HRATE_stdev(28),stride_speed_stdev(28),stride_speed_stdev(28), 'r', 'Linewidth',2)
legend('30th', '27th','26th'); 
xlabel('Stride Speed');
ylabel('Heart Rate');
title('S1 walk to work');
set(gca, 'FontSize',20, 'Fontweight','bold')

% plots the walks between houses in the neighborhood for S1
figure 
plot(cell2mat(HRATE{63}), 'Linewidth',2); 
hold on 
plot(cell2mat(HRATE{69}), 'Linewidth',2); 
hold on 
plot(cell2mat(HRATE{77}), 'Linewidth',2); 
xlabel('Time (sec)');
ylabel('Heart Rate');
title('S1 walk between houses');
set(gca, 'FontSize',20, 'Fontweight','bold');

% plots the walks between houses compared to stride speed in the neighborhood for S1
figure
errorbar(stride_speed_mean(63),HRATE_mean(63),HRATE_stdev(63),HRATE_stdev(63),stride_speed_stdev(63),stride_speed_stdev(63), 'g', 'Linewidth',2)
hold on
errorbar(stride_speed_mean(69),HRATE_mean(69),HRATE_stdev(69),HRATE_stdev(69),stride_speed_stdev(69),stride_speed_stdev(69),'g','Linewidth',2)
hold on
errorbar(stride_speed_mean(77),HRATE_mean(77),HRATE_stdev(77),HRATE_stdev(77),stride_speed_stdev(77),stride_speed_stdev(77),'g','Linewidth',2)
xlabel('Stride Speed');
ylabel('Heart Rate');
title('S1 walk between houses');
set(gca, 'FontSize',20, 'Linewidth',1);

% plots all walks and heart rates compared to stride speed for S1
figure 
errorbar(stride_speed_mean(64),HRATE_mean(64),HRATE_stdev(64),HRATE_stdev(64),stride_speed_stdev(64),stride_speed_stdev(64), 'r', 'Linewidth',2)
hold on
errorbar(stride_speed_mean(44),HRATE_mean(44),HRATE_stdev(44),HRATE_stdev(44),stride_speed_stdev(44),stride_speed_stdev(44),'r','Linewidth',2)
hold on
errorbar(stride_speed_mean(28),HRATE_mean(28),HRATE_stdev(28),HRATE_stdev(28),stride_speed_stdev(28),stride_speed_stdev(28),'r','Linewidth',2)
hold on
errorbar(stride_speed_mean(63),HRATE_mean(63),HRATE_stdev(63),HRATE_stdev(63),stride_speed_stdev(63),stride_speed_stdev(63),'g', 'Linewidth',2)
hold on
errorbar(stride_speed_mean(69),HRATE_mean(69),HRATE_stdev(69),HRATE_stdev(69),stride_speed_stdev(69),stride_speed_stdev(69),'g','Linewidth',2)
hold on
errorbar(stride_speed_mean(77),HRATE_mean(77),HRATE_stdev(77),HRATE_stdev(77),stride_speed_stdev(77),stride_speed_stdev(77),'g','Linewidth',2)
hold on 
errorbar(stride_speed_mean(67),HRATE_mean(67),HRATE_stdev(67),HRATE_stdev(67),stride_speed_stdev(67),stride_speed_stdev(67),'k','Linewidth',2)
xlabel('Stride Speed');
ylabel('Heart Rate');
title('S1 Walks');
set(gca, 'FontSize',20, 'Linewidth',1);
legend('walk to work','','','walk between houses','','','walk back from work'); 