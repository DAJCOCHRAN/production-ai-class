# JHU Production AI - Module 01: Setup VSCode IDE

## 1. Install Visual Studio Code
- Go to the [VS Code download page](https://code.visualstudio.com/).
- Download the installer for your respected Operating System

## 2. Install Remote Explorer Extension

Once installed, open VSCode and click on the Extensions icon (icon with 4 boxes) in the Activity Bar on the left, then search for "Remote Explorer" by Microsoft and install the Remote Explorer extension.

### 2a. Configure and Connect to a Remote Host via SSH
#### PREREQUISITE: you __MUST__ have your studnet Virutal Machine deployed, please follow the [Virtual Machine Instructions](VirtualMachine.md) if not completed before performing these steps

1. **Get Your Virtual Machine IP**
   
   In the Azure Portal, locate your Virtual Machine and click on the Connect Tab. There you will find the username and IP of your machine 

2. **Create Your Remote Host Connection**
   
   Now we will create a connection between your VSCode and your Azure Virtual Machine.
   1. Open the Command Pallet by typing Ctrl + Shift + P and search for **Remote-SSH: Add New SSH Host**
   2. This is where you type your ssh command
      ```shell
      ssh yourUserName@yourVMIP
      ```
   3. Select your prefered config directory or select the first one if no preference
  
3. **Connect to your Azure VM with VSCode**

    Now run Ctrl + Shift + P again, type and select **Remote-SSH: Connect to Host...** and then select the Option that includes your Ip. It will prompt you to give your password. The password was provided from your VM deployment.  Once connected, type exit at any time to exit the VM SSH connection.  If you want a new VSCode session opened at a new directory, simply change to your target directory then type "code ." in the terminal to open a new VSCode SSH Session

## 3. Install Azure Tools Extension

Click on the Extensions icon (icon with 4 boxes) in the Activity Bar on the left, then search for "Azure Tools" by Microsoft and install the extension.

