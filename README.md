## **Fretbuzz**

Fretbuzz adds MIDI notes and text events to PART GUITAR and BASS tracks in Reaper. All notes and text events are placed at the current playhead position.

<img width="704" height="650" alt="Fretbuzz" src="https://github.com/user-attachments/assets/55f6cc41-fe3e-4c19-896c-d0dd13a64c97" />

## **Requirements**  
The simplest way to get scripts working in Reaper is to follow the Milohax Reaper setup guide here: https://guides.milohax.org/en/charting/reaper/. This guide includes installing the SWS Extensions and includes the other files that you need.
Otherwise you need to install SWS Extensions, ReaPack, and Realmgui manually. Note: You can install RealmGui via ReaPack.
https://sws-extension.org/
https://reapack.com/

## **Left Hand Poistion**  

The first twelve buttons place MIDI notes for the left hand position on the fretboard. Using these buttons means that you no longer have to check the position of these notes against the MIDI template. 

<img width="705" height="85" alt="Left-hand-position" src="https://github.com/user-attachments/assets/e55d1650-f82e-4875-b031-4501619ee751" />

## **Left Hand Handmaps**  

The LH Handmap buttons place text events for left hand fingering. A table of variables lets you know which features apply to each text event.

<img width="583" height="377" alt="Left-hand-handmap" src="https://github.com/user-attachments/assets/701bd25c-6846-4168-809e-7e6fc4a2c3b9" />

## **Copy and Paste Animation Notes and Text Events**  

The Copy Paste Animation section allows you to copy sections of animation MIDI notes and text events. The Copy Start and Copy End buttons let you to place two markers to define a section in the MIDI track. Once a section is defined click the Copy button to copy the notes and text events to the clipboard. Then position the playhead where you want the duplicate section to begin and click the Paste button. 

The clipboard remains active while the application is open. 

The Copy button also displays the number of MIDI notes and text events in the clipboard. 

Click the Clear Markers button to remove the section markers.

<img width="666" height="84" alt="Copy-paste-animations" src="https://github.com/user-attachments/assets/b0446eb7-e51b-49a0-8faa-af670d1d24ed" />

## **Right Hand Strum Maps for Bass Guitar**  

The Strum map buttons are for the PART BASS track only. They place text messages that define the right hand animation for the bass player. 

<img width="490" height="83" alt="strum-maps-bass" src="https://github.com/user-attachments/assets/ee7385df-9556-4c8f-a083-f10fd14cd758" />

## Installation
**Note**: This app reqiures a modern version of Reaper to run. 

Download and extract files to your Reaper Scripts folder (C:\Users\<username>\AppData\Roaming\REAPER\Scripts\FretBuzz).

**Note**: You need to have hidden items enabled in **File Explorer** to access the AppData folder. In File Explorer click **View** > **Show** > **Hidden Items**. 

<img width="814" height="558" alt="File-explorer-files" src="https://github.com/user-attachments/assets/fb6fc3ae-5a02-4299-908e-a2de82c8b259" />

In Reaper, click **Actions** > **Show action list**.

In the **Actions** window Click the **New action** button, then click **Load ReaScript**.

<img width="617" height="482" alt="Load ReaScript" src="https://github.com/user-attachments/assets/71760608-df0c-4fe3-8e26-1ed3ca8aad98" />

Browse to C:\Users\<username>\AppData\Roaming\REAPER\Scripts\FretBuzz. Select **Events Toola.lua** and then click the **Open** button.

In the **Actions** window, select **Script: Events Tools.lua** from the list. Click the **Add** button. The **Keyboard/MIDI/OSC Input** window will open. Choose a hotkey for the application.

<img width="924" height="436" alt="Reaper-hotkey-setup" src="https://github.com/user-attachments/assets/0ff3ac7e-df30-465d-9c9b-67258ff5263d" />

Click the **Close** button in the **Actions** window.

Installation is now complete.


