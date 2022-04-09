// Copyright (C) 2022 - University of Montpellier - NIERDING Axel
//
//
// Date of creation: 9 févr. 2022
//// The first part of this code, e.g. initialization, is borrowed from Denis Mottet - Univ Montpellier - France. Available on https://github.com/DenisMot/ScilabDataAnalysisTemplate
//
//dataMeanOverPeriod.sci and displaySignalAndMean.sci is inspired by work of LEPERF Gaël; adapted and modified by NIERDING Axel
//
////
// This algorithm is made for Wisloff protocol : DOI : 10.1097/JES.0b013e3181aa65fc
//
//
//To make you an overall BPM view of your HIIT protocol. This algorithm is made for a Polar H10 and make a mean about different measures such as :
//
//The HIIT condition
//During each intervall (effort and recuperation)
//During effort time
//The time >85% of your max BPM
//The max bpm you reach during HIIT
//A graphic representation of your effort with a line of the goal zone (>85% max BPM) and the BPM mean of your HIIT
//A graphic representation of your effort in terms of blocks of 20s 
//These data tells you more about your vascular stress, an overall cinetic of your recuperation and if you are reach -or not- your goal in BPM terms.
//
//
// **** FIRST : Initialize ****
clear
clc
PRG_PATH = get_absolute_file_path("HIIT.sce");          
FullFileInitTRT = fullfile(PRG_PATH, "InitTRT.sce" );//<- Initialization by InitTRT is useful to simplify the path of your files and compute all your .sci files to make cleaner your code 
exec(FullFileInitTRT); 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//OPEN YOUR FILE AND READ INTO THIS FILE
//

fnameIn = fullfile(DAT_PATH, "HIIT4DT2_01.csv"); // Path of the info file <- You should change the name of the file with the name of your file in DAT folder
Data = csvRead(fnameIn, ";", '.' ,'double', [], [], [], 3)            // Read info file and delete the third lines in header to keep numbers only


BPM = Data(:,3) //Extract the BPM wich correspond to the third colonn 
Time = Data(:,1)//Extract the time in seconds wich correspond to the first colonn 


MaxBPM = 150 // <------------------- Change and put your max BPM here ***********************************************
BPMZoneOfInterest = MaxBPM * 0.85 // <---------- Change and put a coefficient for your zone of interest (0.85 = 85% of your Max BPM)***********************************************




////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A VECTOR WIHICH CONTAINS THE DURATION OF THE WARM UP AND THE EFFORT 


TimeWarmUp = Time(5);                           // get the duration in minutes of the warm-up in the info file
TimeWarmUp = TimeWarmUp.*60                   // Convert warm-up time to seconds

lowLimit = find(Data(:,1) >= TimeWarmUp)      // Finds the indexes where the time >= TimeWarmUp
lowLimit = lowLimit(1)                      // Keep only the lowest time value

endEffort = Time(5) + Time(32);               // get the duration in minutes of the warm-up + effort in the info file
endEffort = endEffort.*60                 // Convert endEffort to seconds

highLimit = find(Data(:,1) <= endEffort) // Finds the indexes where the time <= endEffort
highLimit = highLimit(1,$)              // Keep only the last time value

DataEff = Data(lowLimit:highLimit,1:3)   // creates DataEff which contains the data between lowLimit and highLimit, i.e. the data related to the effort phase

MaxBPMduringHIIT = max(DataEff(:,3)) // Get the max BPM you reach during your HIIT

HardZoneBPM = find(DataEff(:,3) >= BPMZoneOfInterest) //Finds the indexes where the BPM is over your BPM zone of interest 
HardZoneBPM = HardZoneBPM'
TimeOfHardZone = size(HardZoneBPM, 'r') //Get the number of line to know how many seconds you are over your BPM zone of interest
disp("Your Max BPM", MaxBPM, "Max BPM reach during HIIT", MaxBPMduringHIIT, "Time of HardZone in s", TimeOfHardZone)//Disp the result




////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A MEAN OF HIIT


MeanBPMEffCondition = mean(DataEff(:,3))//Make a mean of BPM during the HIIT with a range of time coresponding to the first and the last second of HIIT
disp("Mean of BPM durin the Condition (EFFORT)",MeanBPMEffCondition)//Disp the result



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//PLOT THE HIIT TO GET AN IDEA IN TERMS OF BPM DURING EACH BLOCKS, THE MEAN AND YOUR ZONE OF INTEREST 

scf(1)
// Preparing data for the different axis
x1 = DataEff(:,1)                     // Time data of HIIT
y1 = DataEff(:,3)                    // BPM data of HIIT

x2 = x1 
y2 = x2*0 + MeanBPMEffCondition // Equation of Mean BPM line

x3 = x1
y3 = x3*0 + BPMZoneOfInterest // Equation of your zone of interest line

plot2d(x1,y1,style= color("Green")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x2,y2,style= color("Blue")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x3,y3,style= color("Red")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line


title("BPM during HIIT") //Title of the plot
xlabel("Time in seconds") //Title of the x axis
ylabel("BPM") //Title of the y axis
legend("BPM during HIIT", "Mean of BPM during HIIT", "Zone5 limit", opt=4) //legend of the plot
//

fnamePDF1 = fullfile(RES_PATH, "Figure 1 : BPM during HIIT") //Define the path and the file name 
xs2pdf(scf(1),fnamePDF1) //save in file






////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//CALCULATE THE MEAN PER 1 MINUTES (60 seconds) BLOCK DURING EFFORT'S PERIOD <- You should choose the time you use during your HIIT intervals, here an example with HIIT 1/1


maxTime = max(DataEff(:,1));      // Set the last second of recording 
blockDuration = 60;             // Duration of the block in seconds <- You should change this number with your proper HIIT duration intervals
tBeg = 0 + DataEff(1,1);         // Start of the first period
tEnd = blockDuration + DataEff(1,1);       // End of the first period

//
n=1                             // Will define a row number in meanValues
while tEnd < maxTime         // Create an iterative loop, as long as tEnd < maxTime  
    meanValues (n,1) = dataMeanOverPeriod(DataEff,tBeg,tEnd) // calculates the mean values for each block and implements, in meanValues, the new mean at each loop 
    tBeg  =  tBeg + blockDuration // redefine the beginning of each block at each loop
    tEnd  = tEnd + blockDuration   // redefine the end of each block at each loop
    n = n + 1                 // Add an extra line to meanValue at each loop
end

nbRowMeanValue= size(meanValues,'r')       // find the number of line to know the end of block
blockTime = blockDuration:blockDuration:nbRowMeanValue*blockDuration    // Define block duration vector
blockTime = blockTime'
meanValues (:,1+1)= blockTime                          // add a column with time by blockduration blocks in meanValues30s


disp("Average Values of BPM per 60 s block", meanValues)// disp the result of all intervals

disp("Average Values of BPM during High intervals per 60 s block", meanValues(1:2:$-1,1)) //disp the result of high intervals only 

disp("Average Values of BPM during recovery intervals per 60 s block", meanValues(2:2:$,1)) //disp the result of recuperation intervals only

fullFileName = (RES_PATH + "/Mean_Values_60seconds_HIIT_1.csv");    // Define the path and the file name
print(fullFileName,meanValues)                     // save in file





////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//CALCULATE THE MEAN PER 20 seconds BLOCK DURING EFFORT'S PERIOD OF THE HIIT


Mean = MeanBPMEffCondition //Define the mean by the mean of interest, here the mean of the HIIT condition
maxTime = max(DataEff(:,1));      // Set the last second of recording 
blockDuration = 20;             // Duration of the block in seconds
tBeg = 0 + DataEff(1,1);         // Start of the first period
tEnd = blockDuration + DataEff(1,1);       // End of the first period

//
n=1                             // Will define a row number in meanValues
while tEnd < maxTime         // Create an iterative loop, as long as tEnd < maxTime  
    meanValues (n,1) = dataMeanOverPeriod(DataEff,tBeg,tEnd) // calculates the mean values for each block and implements, in meanValues, the new mean at each loop 
    tBeg  =  tBeg + blockDuration // redefine the beginning of each block at each loop
    tEnd  = tEnd + blockDuration  // redefine the end of each block at each loop
    n = n + 1                 // Add an extra line to meanValue at each loop
end

nbRowMeanValue= size(meanValues,'r')       // find the number of line to know the end of blocktime
blockTime = blockDuration:blockDuration:nbRowMeanValue*blockDuration    // Define block time vector
blockTime = blockTime'
meanValues (:,1+1)= blockTime                          // add a column with time by 20s block in meanValues


disp("Average Values of BPM per 20 s block", meanValues)// disp results of mean values per 20s blockduration

fullFileName = (RES_PATH + "/Mean_Values_20seconds.csv");    // Define the path and the file name
print(fullFileName,meanValues)                     // save in file



graph=displaySignalAndMean(DataEff,tBeg,tEnd,maxTime,blockDuration,Mean)// function to make a plot with your block of 20s



legend("mean BPM (per 20s Block)", "Mean of BPM during HIIT",opt=4)//legend of the plot
fnamePDF2 = fullfile(RES_PATH, "Figure 4 : BPM Effort per 20s blocks)") //
xs2pdf(scf(2),fnamePDF2)           //save figure in RES folder





