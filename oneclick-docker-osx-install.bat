@echo off
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
echo Updateing WSL...
echo it takes about 5 min if you this window is in background or your wifi bad
powershell Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile wsl_update_x64.msi
echo req(dev)
wsl_update_x64.msi /passive
echo Installing WSL...
rem Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
rem Enable Virtual Machine Platform (required for WSL 2)
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
echo when it shows Unix username slowey press 5 times enter
echo and press CTRL+C
echo press N
echo when it shows "root@your pc name" type exit and press enter
echo or if nothing shows press enter
echo [wsl2] > .wslconfig
echo nestedVirtualization=true >> .wslconfig
rem Install a Linux distribution 
wsl --install -d Ubuntu
echo WSL installation completed.
echo installing docker 
wsl sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm
wsl curl -fsSL https://get.docker.com -o get-docker.sh
wsl sh get-docker.sh
wsl sudo dockerd
wsl touch file
ECHO docker run -it \ >> file
ECHO --device /dev/kvm \ >> file
ECHO -p 50922:10022 \ >> file
ECHO -e "DISPLAY=${DISPLAY:-:0.0}" \ >> file
ECHO -v /mnt/wslg/.X11-unix:/tmp/.X11-unix \ >> file
ECHO -e GENERATE_UNIQUE=true \ >> file
ECHO -e MASTER_PLIST_URL='https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist' \ >> file
ECHO sickcodes/docker-osx:ventura >> file
WSL chmod +x file
wsl ./file
