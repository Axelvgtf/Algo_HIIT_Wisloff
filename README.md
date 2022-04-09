# Algo_HIIT_Wisloff
Algorithm pre-prog for HIIT in Wisloff protocol to medical care center or researcher 

# THIS IS ALREADY PRE PROG FOR WISLOFF PROTOCOL

Just change the max of YOUR BPM (line 42) and the coefficient of your BPM zone of interest (line 43) of 'HIIT.sce'

## Aims of this study are:

To make you an overall BPM view of your Wisloff HIIT protocol.
This algorithm is made for a Polar H10 and make a mean about different measures such as : 
* The entire condition
* During each intervall (effort high/low)
* Overview of your time above YOUR BPM zone of interest during your HIIT
* Your max BPM reach during HIIT
* During effort time
* During post effort time
* A graphic representation of your global condition, effort and post effort with mean of your BPM reached and visualisation of your zone of interest in terms of BPM

These data tells you more about your vascular stress, an overall cinetic of your recuperation and if you are reach -or not- your goal in BPM terms.
	
	AlgoHIIT file grouping : 
	
	* `DAT` : data extracted from PolarH10 and convert into .csv
	* `PRG` : HIIT, GlobalCondition and RecuperationPostHIIT script and function include in the script 
	* `RES` : Graphic and results report.
	      

## Usage

* Clone or download the repository
* On your computer, open `GlobalCondition.sce` then run the script with F5 or click the button with grey triangle to make an overview of your HIIT protocol + Recuperation post HIIT in terms of BPM
* On your computer, open `HIIT.sce` then run the script with F5 or click the button with grey triangle to make an overview of your HIIT protocol in terms of BPM
* On your computer, open `RecuperationPostHIIT.sce` then run the script with F5 or click the button with grey triangle to make an overview of your recuperation after your HIIT protocol in terms of BPM.

	  
## Notes 
	  
* Install [Scilab](https://www.scilab.org) scilab on your computer, For mac Users: click [here](https://www.utc.fr/~mottelet/scilab_for_macOS.html)

* Please, convert your .xls or .xlsx data from Polar H10 in .csv and drag it in `DAT`
* The .csv file must be with the first colum is time in seconds and the thirs colums is your BPM recorded by your Polar H10

* Do not modify the names and organisation of the directories.
  The `DAT`+`PRG`+`RES` structure is expected when initialising in `InitTRT.sce`
  
* You should modify in HIIT.sce at line 42 YOUR max BPM and line 43 the coefficient of your BPM zone of interest during Effort 


Don't hesitate to tell me if you have any issues with the algorithm or if you want help to make it better 

Enjoy :)

-Axelvgtf
