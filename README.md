# Description
Script searches the AzerothCore repository for all available modules and clones the ones that you select.

Note: If the eluna lua mod is one of the selected modules the script automatically downloads the additional eluna engine dependency.  No need to download separately

## **Setup:**
1. Download script
2. Open script with editor of choice and change first line of script to match the folder you have AzerothCore cloned to:
![Imgur](https://i.imgur.com/rHSzQmh.png)
3. Script will download all modules into the "modules" folder of your AzerothCore repository:
![Imgur](https://i.imgur.com/MzH07Fv.png)

## **Running the script:**
1. Navigate to the location you saved the script and double-click to run it
2. Script searches Github and displays a popup of all available modules
3. Check the boxes for the modules that you want
NOTE: Any modules already present in your modules folder will be checked by default
![Imgur](https://i.imgur.com/kXeNNhK.png)
4. Sit back and wait.  Powershell will return to the prompt once finished
5. You can verify modules were downloaded by looking at your modules folder:
![Imgur](https://i.imgur.com/dotgIbc.png)
