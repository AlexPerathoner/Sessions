# Sessions
Safari extension to save your working sessions

Have you ever been working on a project, with dozens of tabs open, and wondered how to save that window?
With *Sessions* you can easily save them, to re-open them whenever you'll want to!

## Features
### New in 1.6:
- You can now reorder sessions by dragging them in the tabl
- Settings are moved to the settings button
- Auto-update: when opening a session in auto-update mode all changes are automatically saved
- Search bar is now more powerful and scans urls and tabs' titles, too!

### New in 1.5:
- You can now replace a saved session with the current workspace
- Option button is gone - right click on a session to display all the available options

### New in 1.4:
- You can now choose if you want to ignore or consider pinned tabs when saving your sessions
- Context menu has a new look

### New in 1.3:
- **Pinned** tabs are now no longer part of sessions and will therefore be ignored when restoring a session

<img align="right" margin="10px" src="https://raw.githubusercontent.com/AlexPerathoner/Sessions/master/Screens/PrivateDemonstration.mov" width="40%"></img>

### New in 1.2:
- Save and open **private** sessions! <sup>[1](#note1)</sup>
- Open non-private sessions in private windows!

<br/>

### New in 1.1:
- Export as json
- Rename sessions 
- Search


<a name="note1"></a><sup>1</sup>: Note that since there are no public APIs avaible to open a private window I used the stratagem of sending a keystroke event to safari. This means that the function could sometimes fail and restore the session in a different window from the one opened.</mark>


## Installation
Download the [latest release](https://github.com/AlexPerathoner/Sessions/releases/latest) and copy the file Sessions.app into your Application's folder. Open it.

![Welcome Window](https://raw.githubusercontent.com/AlexPerathoner/Sessions/master/Screens/welcomeScreen.png)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FAlexPerathoner%2FSessions.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FAlexPerathoner%2FSessions?ref=badge_shield)

Safari will warn you that this extension can read sensible information from every website. That's because *Sessions* needs a high level read permission to get the URLs of the websites you have open. *Sessions* won't ever read any personal information.

As you enable the extension from the Safari's settings window you should see a new icon appear in the bar.

### Actions
* **Click** on the **save** button to store the current working session <sup>[2](#note2)</sup> 
* **Double click** on a previously saved to re-open it
* **Click** on the **settings icon** next to the name of the session to view some other actions:
	* **Restore** - Same as double-click action
	* **Remove** - Deletes the sessions (Caution! <mark>**This action is irreversible!**</mark>)
	* **Rename** - Same as one-click action. Lets you rename the session (the default name is the title of the first tab open when you clicked on *save*)
	* **Export** - Creates a .json file in the Downloads folder with every information *Sessions* has stored concerning about that session


<a name="note2"></a><sup>2</sup>: Note that a session only includes the tabs of your current window. <mark>**Other windows won't be included.**</mark>

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE.md](LICENSE.md) file for details



[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FAlexPerathoner%2FSessions.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FAlexPerathoner%2FSessions?ref=badge_large)