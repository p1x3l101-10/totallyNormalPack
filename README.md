# How to set up:
1. Edit `pack.toml` to fit your needs
  - This includes changing the name, pack version, minecraft version, and modloader versions.
  - If you choose to remove `pack.toml`, and `index.toml` to regenerate, here are the required values:
    - `lwjgl3 = "<VERSION>"` or `lwjgl = "<VERSION>"` (Only one is required, having both is undefined)
    - `unsup = "1.1-pre9"`
2. Edit the `source` field in `unsup.ini` to point to this repository
3. Run `packwiz refresh` to recalculate hashes
4. Add a `LICENSE` file for your pack
  - DO NOT remove the `LICENSE.template` file, it is required to be there as per clause 1 of the license
5. Write a new `README` for your modpack
6. Create a git tag, and push your changes and tags
    - This will automatically create a release containing both prismlauncher and curseforge exports

# Notes
- If you include an `options.txt` file, anyone who changes the options on their game will have them overridden on restart, use a default options mod
- [You can sign the modpack](https://git.sleeping.town/unascribed/unsup/wiki/Signing)

# Credits
[unsup](https://git.sleeping.town/unascribed/unsup)
[packwiz](https://github.com/packwiz/packwiz)