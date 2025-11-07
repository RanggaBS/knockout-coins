# Installation

## Scholarship Edition (SE) - PC

### 🔹 SE Requirements

- [Derpy’s Script Loader (DSL)](http://bullyscripting.net/dsl/about.html) — _latest version_
- (Optional) [More Scripts to Replace (MSR) v2.0](https://www.youtube.com/post/UgkxfWkBF-wHg9PS4jQ4PKF-Z3LByiUikpS3)

### 📦 With DSL (Recommended)

1. Make sure DSL is installed in your Bully directory. It should contain a folder like:

   ```plaintext
   (bully_game_directory)/_derpy_script_loader/
   ```

2. Copy the folder `KnockoutCoins` from `KnockoutCoins_SE/` into:

   ```plaintext
   (bully_game_directory)/_derpy_script_loader/scripts/
   ```

3. Launch the game — the mod will load automatically!

---

## Anniversary Edition (AE) - Android

### 🔹 AE Requirements

- [More Scripts to Replace (MSR) v2.0](https://www.youtube.com/post/UgkxfWkBF-wHg9PS4jQ4PKF-Z3LByiUikpS3) — Optional, but recommended

### 📦 Easy Installation (Using MSR 2.0)

1. Install **More Scripts to Replace (MSR) v2.0** following its included instructions.
2. Depending on the variant you choose:
   2a. If you choose the **STimeCycle** version, copy the `STimeCycle.lur` file into:

   ```plaintext
   /storage/emulated/0/Android/data/com.rockstargames.bully/files/BullyOrig/MSR_II/GROUP_01_STC/
                                                                                        (or 02)
   ```

   Then rename the file to `MOD_1.lur`, or other than 1, depending on your load order

   2b. If you choose the **non-STimeCycle** version, copy the one of the `.lur` file into:

   ```plaintext
   /storage/emulated/0/Android/data/com.rockstargames.bully/files/BullyOrig/MSR_II/GROUP_03_NonSTC/
   ```

   Then rename the file to `MOD_1.lur`, or other than 1, depending on your load order

3. MSR will automatically load the `.lur` file on launch.

### ⚙️ Manual Installation (Without MSR)

If you prefer manual installation:

1. Open **IMG Tool** (available on Play Store: [IMG Tool Android](https://play.google.com/store/apps/details?id=by.lsdsl.gta.imgtool&hl=id)).
2. Navigate to:

   ```plaintext
   /storage/emulated/0/Android/data/com.rockstargames.bully/files/BullyOrig/Scripts/
   ```

3. Open `Scripts.img`.
4. Click **Add files(s) with replace**.
5. From the extracted mod folder, open `STimeCycle/` or `non-STimeCycle/` (depending on whichever variant you choose).
6. Select **STimeCycle.lur** or **SLvesEff.lur** (choose one `.lur` file inside the folder).
7. Click **Rebuild**.
8. Done! Launch the game and enjoy.

## 🧩 Configuration (AE)

You can customize the mod behavior through its configuration file.
All config files are located in:
`/storage/emulated/0/Games/BullyAE/Mods/KnockoutCoins/config/`

1. Copy the `config/` folder from the mod package (contains `config_ae.lua` and `config_ae.lur`) to the directory above.
2. You can edit `config_ae.lua` to adjust values such as:

   - Coin values for penny and dollar
   - Coin collection radius
   - Bobbing animation toggle
   - Minimum and maximum rewards for each faction

3. After making changes, compile your modified `.lua` file into `.lur` using the Android Lua compiler app shown in this YouTube tutorial:  
   ▶️ [Lua Compiler APK for Bully Modding](https://youtube.com/watch?v=eO64awFgCCA)
4. Replace the existing `config_ae.lur` in the same path with your newly compiled one.

---

## PS2

You must install this mod **manually** by replacing the script file inside your game’s `Scripts.img`, and then reinserting it into the game ISO.

**Steps:**

1. Extract your PS2 game ISO using a tool like **UltraISO**, **PowerISO**, or similar.
2. Open the `Scripts.img` file located in the extracted game directory using **IMG Tool 2.0** or **IMG Factory**.
3. Replace the corresponding file inside `Scripts.img` with the one from this mod (either `STimeCycle.lur` or non STimeCycle like `SLvesEff.lur` or `SWinEff.lur`, depending which variant you choose).
4. Rebuild the `Scripts.img`.
5. Reinsert the modified `Scripts.img` back into your game ISO.
6. Save the ISO, then transfer it back to your console or emulator.
