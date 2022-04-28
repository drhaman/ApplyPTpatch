# ApplyPTpatch.ps1

The purpose of this powershell is to have a single command line to run for applying PeopleTools patches to databases.
There is a path for Change Assistant that is hardcoded on line 33 that can be updated for your needs.

## General requirements
- Install the PeopleTools Client of the version you will be patching to, `PTC-DPK-WIN8.59.08-1of1.zip` for example.
- The difference you will likely need to make is where to install Change Assistant (CA).
  - Line 33 expects CA to be in `C:\psoft\ca`
  - The way we have been using is to install it into a folder by tools release `C:\psoft\ca\85908` for this example.
  - The client should also install either an Oracle or Microsoft client for the target DB, `C:\PT8.59.08_Client_MSS`.
- Launch the new CA `C:\psoft\ca\85908\changeassistant.exe` and configure your target databases in this CA to use this new client. Also configure CA like you normally would for a PeopleTools patch. You do not need PUM Source or EM Hub defined for PeopleTools Patching.
- If you are on a new system you may have create your staging, output and download locations, create ODBC if needed.
- You should now be able to close CA.

## Using ApplyPTpatch.ps1
- Open an Administrative Powershell session
- For this example we will have the powershell in `C:\psoft\ca`.
- This command will apply PATCH859 to the target db DEV.

```
cd C:\psoft\ca
.\ApplyPTpatch.ps1 -ptversion 85908 -targetdb DEV
```
As long as your target DB's are created in CA you can just keep repeating the command and change the targetdb value
```
.\ApplyPTpatch.ps1 -ptversion 85908 -targetdb TEST
.\ApplyPTpatch.ps1 -ptversion 85908 -targetdb UAT
```
