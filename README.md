# waybar

My personal configuration for [waybar](https://github.com/Alexays/Waybar)
I will do my best to comment the configuration file. Feel free to crib/steal this for your own personal use.

## Dependencies

For the bundled `mediaplayer.py` (this is from [waybar](https://github.com/Alexays/Waybar/tree/master/resources/custom_modules)) to work,
You must have `gobject-introspection` installed from your package manager so that you can install `PyGObject` with `pip`.
If you're on Arch Linux, you can directly install `pacman -S python-gobject`.

NOTE: If you use a Python version manager, such as [asdf](https://asdf-vm.com/#/), installing `python-gobject` MAY NOT work.
This is because installing `python-gobject` installs it globally, and your versioned Python will have it's own `pip` and package directory.
If that's the case, then `pip install PyGObject` would be the way to go.
That being said, running `waybar` in `sway` will use the system Python, unless you set it up to use your version manager Python.

## Usage

Run `./install.sh` to link the configuration files to the proper location
