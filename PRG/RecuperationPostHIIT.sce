// Copyright (C) 2022 - Corporation - NIERDING Axel
//
// About your license if you have any
//
// Date of creation: 3 avr. 2022
//
//// The first part of this code, e.g. initialization, is borrowed from Denis Mottet - Univ Montpellier - France. Available on https://github.com/DenisMot/ScilabDataAnalysisTemplate
//// dataMeanOverPeriod.sci and displaySignalAndMean.sci is inspired by work of LEPERF Gaël; adapted and modified by NIERDING Axel
//
//READ ME
//
// This algorithm is made for Wisloff protocol : DOI : 10.1097/JES.0b013e3181aa65fc
//
//
//This algorithm is made for a Polar H10 and make a mean about different measures such as :
//
//The recuperation period post HIIT protocol
//The recuperation period per 5 min blocks post HIIT protocol
//A graphic representation of your recuperation period with the mean values of the blocks
//
//These data tells you more about your vascular stress, an overall cinetic of your recuperation and if you are reach -or not- your goal in BPM terms.

// **** FIRST : Initialize ****
clear
clc
PRG_PATH = get_absolute_file_path("RecuperationPostHIIT.sce");          
FullFileInitTRT = fullfile(PRG_PATH, "InitTRT.sce" );//<- Initialization by InitTRT is useful to simplify the path of your files and compute all your .sci files to make cleaner your code 
exec(FullFileInitTRT); 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//OPEN YOUR FILE  AND READ INTO THIS FILE
//

fnameIn = fullfile(DAT_PATH, "HIIT4DT2_01.csv"); // Path of the info file
Data = csvRead(fnameIn, ";", '.' ,'double', [], [], [], 3)            // Read info file and delete the third lines in header to keep numbers only
BPM = Data(:,3) //Extract the BPM wich correspond to the third colonn 
Time = Data(:,1)//Extract the time in seconds wich correspond to the first colonn 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A VECTOR WIHICH CONTAINS THE DURATION OF THE WARM UP, THE EFFORT AND THE RECUPERATION (POST EFFORT) OF THE CONDITION 


endEffort = Time(5) + Time(32);               // get the duration in minutes of the warm-up + effort in the info file
endEffort = endEffort.*60                 // Convert endEffort to seconds

highLimit = find(Data(:,1) <= endEffort) // Finds the indexes where the time <= endEffort
highLimit = highLimit(1,$)              // Keep only the last time value

tPostEffCondition = (Data(highLimit,1))         // Get the first second after the effort corresponding to the first second of recuperation periods
tEndCondition = max(Data(:,1))         //Get the last second of recuperation periods

DataRec = Data(highLimit:$,1:3) //Get the range of your post effort period

TimeOfPostEffCondition = find (Data(:,1) >= tPostEffCondition & Data(:,1) <= tEndCondition)    //Finds the indexes the time of all recuperation periods
TimeOfPostEffCondition = TimeOfPostEffCondition'

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A MEAN OF BPM DURING THE RECUPERATION PERIOD OF THE CONDITION 

MeanBPMPostEffCondition = mean(Data(TimeOfPostEffCondition,3))//Mean of recuperation period
disp('Mean of BPM Post Effort in Condition corresponding to the recuperation period',MeanBPMPostEffCondition)//Disp the mean of recuperation period



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE THE MEAN PER 5 MINUTES (300 seconds) BLOCK DURING RECUPERATION PERIOD OF THE CONDITION 


maxTime = max(DataRec($,1));      // Set the last second of recording 
blockDuration = 300;             // Duration of the block in seconds
tBeg = 0 + (DataRec(1,1));         // Start of the first period
tEnd = blockDuration + DataRec(1,1)    ;       // End of the first period

//
n=1                             // Will define a row number in meanValues
while tBeg < maxTime           // Create an iterative loop, as long as tEnd < maxTime  
    meanValues (n,1) = dataMeanOverPeriod(DataRec,tBeg,tEnd) // calculates the mean values for each block and implements, in meanValues, the new mean at each loop 
    tBeg  =  tBeg + blockDuration // redefine the beginning of each block at each loop
    tEnd  = tEnd + blockDuration  // redefine the end of each block at each loop
    n = n + 1                 // Add an extra line to meanValue at each loop
end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//PLOT THE CONDITION TO GET AN IDEA OF THE RECUPERATION PERIOD POST EFFORT IN TERMS OF BPM AND IN BLOCKS


scf(1)
//Preparing data for the different axis
x1 = Data(TimeOfPostEffCondition,1)                     // Time data of recuperation period
y1 = Data(TimeOfPostEffCondition,3)                    // BPM data of recuperation period

x2 = TimeOfPostEffCondition(1:blockDuration:$,1)                     // Time data recuperation period with incrementation per blockDuration
y2 = meanValues(:,1)              // BPM data from meanValues per blockDuration incrementation

plot2d(x1,y1,style= color("blue")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

plot2d(x2,y2,style= color("red")) // Define x and y axis , and the color
gce().children.thickness = 3;               // Enlargement of the plot line

title("BPM during recuperation post HIIT ") //Title of the plot
xlabel("Time in seconds") //Title of the x axis
ylabel("BPM") //Title of the y axis
legend("BPM during recuperation period post HIIT","BPM per 5min blocks during recuperation period post HIIT",opt=1) //Legend of the plot 


fnamePDF1 = fullfile(RES_PATH, "Figure 1 : BPM over condition and per 5min blocks ") //Define the path and the file name <- you should change the number if you change blockduration period
xs2pdf(scf(1),fnamePDF1) //save in file


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//MAKE A MODIFICATION OF THE LAST MEAN VALUES BECAUSE THE DURATION OF RECUPERATION IS NOT A PERFECT MULTIPLE OF BLOCKDURATION PERIOD

LasttEnd = maxTime ;                       // defines the end of the trial
LasttBeg = tEnd - 2*blockDuration  ;          // defined the end of the previous period
lastMeanValues = dataMeanOverPeriod(DataRec,LasttBeg,LasttEnd); // calculates the mean values of the last block
lastBlockDur = LasttEnd - LasttBeg      // duration of the last block
meanValues ($,:) = lastMeanValues    // implements, in meanValues, the mean of the last block
nbRowMeanValue= size(meanValues,'r')        // find the number of line to know the end of blockTime
blockTime = blockDuration:blockDuration:nbRowMeanValue*blockDuration    // Define blockduration vector 
blockTime = blockTime'
blockTime ($,1) = blockTime ($-1,1) + lastBlockDur      //Time correction of the last block
meanValues (:,$+1)= blockTime       //// add a column with time by blockDuration block in meanValues


disp("Average Values of BPM per 5 min block Post Effort corresponding to the recuperation period", meanValues)// You should change the period if you change blockduration period
disp("Attention, the last block has a duration in seconds of", lastBlockDur) //disp the duration of the last block

fullFileName = (RES_PATH + "/Mean_Values_5min.csv");    // Define the path and the file name <- you should change the number if you change blockduration period
print(fullFileName,meanValues)                     // save in file




