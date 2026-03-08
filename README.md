# `inso APB Config + Windows Optimizations`

# Installation
Drag and drop the folders into your APB Reloaded main directory and replace everything when prompted to.

For example, if you wish to install my graphics open the `Graphics` folder and drag and drop the `APBGame` folder into your own APB Reloaded main directory where your own `APBGame` folder is located but ***NOT inside `APBGame` itself!*** If Windows prompts you to replace files then you're doing it right. If not, check whether you are placing the files in the correct directory.

The only config that requires one additional step is localization because you need to add the `-language=1031` launch argument to your shortcut in case you haven't already done that.

# Launch arguments
+ `-language=1031` - Sets game to load with custom localization (required for localization).
+ `-nomovies` / `-nomoviesstartup` - Removes loading screens.
+ `-nosplash` - Removes initial splash screen upon boot (GFAC logo cannot be removed).
+ `-nosteam` - Disables Steam integration, including Steam auto-login.

<details>
  <summary>Click here for an image example of launch arguments</summary>
  
![targetfield](https://i.imgur.com/o0vQdAr.png)

</details>


Example correct Target field path: <br >
`"C:\Program Files (x86)\Steam\steamapps\common\APB Reloaded\Binaries\APB.exe" -language=1031 -nomovies -nosplash`
> [!CAUTION]
> Be sure to add a space after the quotations and before the dash, as well as between each launch argument as shown in the examples.

> [!IMPORTANT]
> Whenever a game update comes out you must open the default APB launcher, let it update, then close the launcher, reinstall your desired configs and launch the game from your desktop shortcut. Do NOT create new APB shortcuts every time there is an update, it is unnecessary. Creating a shortcut of APB.exe is a single-time thing, you DON'T need to re-do it for updates/patches.

> [!NOTE]
> In order to revert everything back to vanilla and start over, open the default APB launcher, click Options -> Repair and let it finish. Once that is done you may close the launcher and start over with modding your game.
