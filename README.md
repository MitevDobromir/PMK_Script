# PMK Dependency Installer

This is a simple PowerShell script for installing all the necessary dependencies for PMK.

## How to Use

1. Download the script and open **cmd** in the same location as the file.

2. Run this command:

<pre style="background-color: black; color: white; font-size: 20px; padding: 10px; border-radius: 5px;">
powershell -ExecutionPolicy Bypass -File .\install_python_and_libraries.ps1
</pre>

This will install(if not present): Python(most recent), pip, mlagents, torch,
torchvision, torchaudio, and protobuff(3.20.3)

Here is what the output should be 

![image](https://github.com/user-attachments/assets/3a81c831-1648-4cfc-ac6a-4e84eeae461e)
