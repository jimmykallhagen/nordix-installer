# Nordix installer


I wrote an installer last year that I have used to test and use Nordix - Yggdrasil. The one I am writing here is more of a realese ready installer.

---

## First impressions
An installer is the first impression you get of a system, but its appearance has nothing to do with whether a system is modern or not, whether a system is technically good or bad, but it is a first impression and using ready-made installers like Calamares gives a professional impression.

---

## Why not Calamarer?

Calamares is great for handling standard installations, perfect for giving the user smooth system setup with location, language, keyboard, partitioning, formatting your drive nad configure a bootloader.
But when a system like Nordix deviates from this standard with zfs and its various vdev layouts it becomes problematic, not using a traditional bootloader but instead using Zfsbootmenu means that you have to put more work into "hacking" Calameres than it takes to write your own installer.
I have had different ideas for how this setup should look, an installer written with python GUI or similar has been one of my thoughts at first, but then I think that for a first release I should not bother too much with it. Writing a graphical installer also causes possible problems with all the different hardware, writing an installer with Bash and Gum that runs directly on a Linux console means that it works on all computers, without extra drivers

---

## Nordix installer
The philosophy behind the Nordix installer is that it should be modular and easy to understand. One idea I have is that you should be able to use the Nordix installer easily for your own projects. If you want to share your system, you should be able to easily see in the Nordix installer which parts you need to replace to apply your own system. This also means that it will be easier to contribute to the Nordix installer if you would like to do so.

> You could think of the Nordix installer as a universal Arch ZFS installer.

---

# Contribute

Things I write tend to be a bit enthusiastic, but I have to let it be, nothing is written in stone and if you are someone who wants to contribute to this project and maybe make it have a less enthusiastic and more professional impression, you are welcome to help me with this, you are welcome to help and contribute even if you don't want to change the impression of course
