# YakLOG
## What's it do?
This program will open a .PMED format datalog from the DSC Tuning software. It outputs some plots, but most importantly it converts the file to a .CSV file that can be then be imported into datazap.me or other csv viewers.

***

## How to use
1. Open the YakLOG.exe file. After a few seconds a dialog will appear for opening a "new" datalog. Navigate to and select your .PMED file. **This is also the file that will be converted into .csv**
2. A second dialog will open to select an "old" datalog. *This datalog will only be used for the histogram plots, and will not be converted to .csv*
3. A dialog will ask what speed to use for trimming. This will remove any entries where the vehicle speed is below the entered speed.
4. A last dialog will appear asking if zero velocity values should be removed from histograms. Removing these may help make the data easier to read, especially if it was taken during normal street driving where zero wheel velocity is common. *This does not impact the data that is saved to .csv"*
5. Last a dialog appears to ask if you wish to save the .csv.

### What do the plots mean?
#### Histograms
See the below video for some ideas

<a href="http://www.youtube.com/watch?feature=player_embedded&v=DwXxWEMIsT4
" target="_blank"><img src="http://img.youtube.com/vi/DwXxWEMIsT4/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
#### Plots
I don't know, they seemed like a good idea to make
#### Distribution data
This is a different way to look at histogram data. For low speed it shows the rebound/compression split. For the med and high speed it shows what percentage makes it into that bucket. Not sure if it is useful.


***

## How to install
1. Download an installer from the releases tab.
2. Open this file, and approve any security requests.
The installer and program were complied using MATLAB>
