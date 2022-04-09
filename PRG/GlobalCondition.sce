// Copyright (C) 2022 - Corporation - Author
//
// About your license if you have any
//
// Date of creation: 7 avr. 2022
//// The first part of this code, e.g. initialization, is borrowed from Denis Mottet - Univ Montpellier - France. Available on https://github.com/DenisMot/ScilabDataAnalysisTemplate
//
//
//dataMeanOverPeriod.sci and displaySignalAndMean.sci is inspired by work of LEPERF Gaël; adapted and modified by NIERDING Axel
//
////
// This algorithm is made for Wisloff protocol : DOI : 10.1097/JES.0b013e3181aa65fc
//
//
//To make you an overall BPM view of your HIIT protocol and recuperation period. This algorithm is made for a Polar H10 and make aan overview about different measures such as :
//
//The HIIT condition
//The recuperation period
//During effort time
//A graphic representation of your condition with differents periods (warm-up, HIIT, recuperation) and a mean line of your entire condition
//A graphic representation of your condition in terms of blocks of 300s
//These data tells you more about your vascular stress, an overall cinetic of your recuperation and if you are reach -or not- your goal in BPM terms.
//
//
// **** FIRST : Initialize ****
clear
clc
PRG_PATH = get_absolute_file_path("GlobalCondition.sce");          
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


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A MEAN OF THE ALL CONDITION  (EFFORT + RECUPERATION)

tBegCondition = min(Data(:,1))         // Set the first second of recording
tEndCondition = max(Data(:,1))        // Set the last second of recording
TimeOfAllCondition = find (Data(:,1) >= tBegCondition & Data(:,1) <= tEndCondition)//Find in Data the duration between the first second of recording and the last one

MeanBPMOverTheCondition = mean(Data(TimeOfAllCondition,3))//Make a mean of BPM during the all condition with a range of time coresponding to the first and the last second of recording
disp("Mean of BPM during all the Condition",MeanBPMOverTheCondition)//Disp the result

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A VECTOR WIHICH CONTAINS THE DURATION OF THE WARM UP, THE EFFORT AND THE RECUPERATION (POST EFFORT) OF THE CONDITION 


TimeWarmUp = Time(5);                           // get the duration in minutes of the warm-up in the info file
TimeWarmUp = TimeWarmUp.*60                   // Convert warm-up time to seconds

lowLimit = find(Data(:,1) >= TimeWarmUp)      // Finds the indexes where the time >= TimeWarmUp
lowLimit = lowLimit(1)                      // Keep only the lowest time value

endEffort = Time(5) + Time(32);               // get the duration in minutes of the warm-up + effort in the info file
endEffort = endEffort.*60                 // Convert endEffort to seconds

highLimit = find(Data(:,1) <= endEffort) // Finds the indexes where the time <= endEffort
highLimit = highLimit(1,$)              // Keep only the last time value

DataEff = Data(lowLimit:highLimit,1:3)   // creates DataEff which contains the data between lowLimit and highLimit, i.e. the data related to the effort phase

tPostEffCondition = (Data(highLimit,1))         // Get the first second after the effort corresponding to the first second of recuperation's period
tEndCondition = max(Data(:,1))         //Get the last second of recuperation's period

TimeOfPostEffCondition = find (Data(:,1) >= tPostEffCondition & Data(:,1) <= tEndCondition)    //Finds the indexes the time of all recuperation's period
TimeOfPostEffCondition = TimeOfPostEffCondition'

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//Plot the condition to get an idea of the condition in terms of BPM during your Warm-Up, your HIIT and your recovery post HIIT
scf(1)
// Preparing data for the different axis
x1 = Time                     // Time data 
y1 = BPM                    // BPM data

x2 = DataEff(:,1)                     // Time data of HIIT
y2 = DataEff(:,3)                    // BPM data of HIIT

x3 = Data(TimeOfPostEffCondition,1) // Time data of recuperation
y3 = Data(TimeOfPostEffCondition,3) // BPM data of recuperation

x4 = Time // Time Data
y4 = Time*0 + MeanBPMOverTheCondition // Equation of mean line of your BPM during over condition

plot2d(x1,y1,style= color("blue")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x2,y2,style= color("grey"))// Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x3,y3,style= color("red"))// Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x4,y4,style= color("black"))// Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

title("BPM over condition") //Title of the plot
xlabel("Time in seconds") //Tile of x axis
ylabel("BPM") // Title of y axis
legend("BPM during warm up","BPM during HIIT", "BPM during recovery","Mean of BPM during entire condition" ,opt=4)//legend of the plot
//
fnamePDF1 = fullfile(RES_PATH, "Figure 1 : BPM over condition ")//Define the path and the file name
xs2pdf(scf(1),fnamePDF1) //save in file


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE THE MEAN PER 10 MINUTES (600 seconds) BLOCK DURING RECUPERATION'S PERIOD OF THE CONDITION 

maxTime = max(Data(:,1));      // Set the last second of recording 
blockDuration = 300;             // Duration of the block in seconds
tBeg = 0 + (Data(1,1));         // Start of the first period
tEnd = (Data(1,1)) + blockDuration  ;       // End of the first period

//
n=1                             // Will define a row number in meanValues
while tBeg < maxTime         // Create an iterative loop, as long as tEnd < maxTime  
    meanValues (n,1) = dataMeanOverPeriod(Data,tBeg,tEnd) // calculates the mean values for each block and implements, in meanValues, the new mean at each loop 
    tBeg  =  tBeg + blockDuration // redefine the beginning of each block at each loop
    tEnd  = tEnd + blockDuration  // redefine the end of each block at each loop
    n = n + 1                 // Add an extra line to meanValue at each loop
end

nbRowMeanValue = size(meanValues,'r')       // find the number of line to know the end of block time
blockTime = blockDuration:blockDuration:nbRowMeanValue*blockDuration    // Define block time vector
blockTime = blockTime'
meanValues (:,$+1)= blockTime                          // add a column with time by blockduration block in meanValues

disp("Average Values of BPM per 10 min block over period", meanValues)//disp the result
//disp("Attention, the last block has a duration in seconds of", lastBlockDur)


fullFileName = (RES_PATH + "/Mean_Values_Global_Condition_10min_1.csv");    // Define the path and the file name
print(fullFileName,meanValues)                     // save in file


//Plot the condition to get an idea of the condition in terms of BPM during each blocks and the recuperation post effort

scf(2)
//Preparing data for the different axis
x1 = Data(1:blockDuration:$,1)                     // Time data 
y1 = meanValues(:,1)                    // BPM data

x2 = Time // Time Data
y2 = Time*0 + MeanBPMOverTheCondition // Equation of mean line of your BPM during over condition


plot2d(x1,y1,style= color("blue")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x2,y2,style= color("black"))// Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

title("BPM over condition (mean per 5min block)") //Title of the plot
xlabel("Time in seconds") //Title of x axis
ylabel("BPM") //Title of y axis
legend("BPM per 5min block during recovery period post HIIT", "Mean of BPM during entire condition", opt=1) //Legend of the plot
//
fnamePDF2 = fullfile(RES_PATH, "Figure 1 : BPM over condition ") //Define the path and the file name
xs2pdf(scf(2),fnamePDF2) //Save in file
