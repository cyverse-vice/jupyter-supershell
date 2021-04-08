cp /SuperShell/offline.sh ~/.offline.sh
cp /SuperShell/interactive.txt ~/.interactive.txt
cp /SuperShell/supershellhelp.txt ~/supershellhelp.txt
cp /SuperShell/ruledir.txt ~/ruledir.txt
cp /SuperShell/add_interactive.sh ~/add_interactive.sh
cp /SuperShell/disable_help.sh ~/disable_help.sh
cp /SuperShell/enable_help.sh ~/enable_help.sh
cp /SuperShell/supershellinfo.txt ~/.supershellinfo.txt
cp -r /SuperShell/SuperShellRules ~/
cp -r /SuperShell ~/SuperShell
mkdir ~/SuperShell/SuperShellHistory
echo "bash ~/.offline.sh" >> ~/.bash_profile
echo "exit" >> ~/.bash_profile
source ~/.bash_profile