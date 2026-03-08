# `inso APB Config + Windows Optimizations`

Cette configuration contient mes propres réglages pour **APB Reloaded**, inspirés de la configuration originale de Flaws.  
Elle vise à optimiser la performance et la réactivité in-game. un script afin d'optimiser lexecutable d'apb pour Windows vous est fourni si vous souhaitez.

# `1` Installation
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

# Infos supp

> [!IMPORTANT]
> Whenever a game update comes out you must open the default APB launcher, let it update, then close the launcher, reinstall your desired configs and launch the game from your desktop shortcut. Do NOT create new APB shortcuts every time there is an update, it is unnecessary. Creating a shortcut of APB.exe is a single-time thing, you DON'T need to re-do it for updates/patches.

> [!NOTE]
> In order to revert everything back to vanilla and start over, open the default APB launcher, click Options -> Repair and let it finish. Once that is done you may close the launcher and start over with modding your game.

# `2` Windows Optimization for APB executable (Performance & Latency Optimization Toolkit)
Ce script applique des réglages système pour **Valorant** afin d'améliorer les performances, réduire l'input delay et diminuer la latence réseau.  
Une interface graphique simple vous permet de choisir les optimisations à appliquer. Tout est **sûr**, **efficace** et **entièrement réversible**.

# Pour appliquer une/des optimisations
Faites un **clic droit** sur le fichier `.ps1` → **"Exécuter avec PowerShell"**.  
Le script demandera automatiquement les droits administrateur. si vous navez pas lautorisation dexcuter des script powershell activer cela via:
Une fois cela fais, Une inteface graphique s'ouvrira avec des cases à cocher. Voici ce que fait chaque option en clair:

<details>
  <summary>Click here for an image example of the script (interface GUI)</summary>
  
![targetfield](https://i.imgur.com/tjbG35y.png)

</details>


| Option | Ce que ça fait |
|---|---|
| **All-in-One** | Applique tout d'un coup *(recommandé)* |
| **CPU Priority** | Donne plus de ressources à Valorant pour qu'il tourne mieux |
| **Network Optimization** | Réduit le ping et stabilise la connexion en jeu |
| **GPU High Performance** | Force Windows à utiliser votre carte graphique à fond pour Valorant |
| **RunAsAdmin** | Lance Valorant en administrateur pour éviter certains problèmes |
| **Firewall** | Autorise Valorant dans le pare-feu pour éviter les coupures réseau |
| **Defender Exclusion** | Empêche l'antivirus Windows de ralentir le jeu en arrière-plan |
| **Remove all** | Supprime tout et remet Windows comme avant |

> [!IMPORTANT]
> Si le jeu refuse de se lancer après l'optimisation **RunAsAdmin**, cochez **"Remove all optimizations"** et cliquez Apply pour tout annuler.

> [!NOTE]
> Pour tout réinitialiser, cochez simplement **"Remove all optimizations"** puis cliquez sur **Apply**.

---

<p align="center">
  <sub>©insopti — <a href="https://guns.lol/inso.vs">guns.lol/inso.vs</a> | For personal use only.</sub>
</p>
