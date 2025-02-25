# Initialize
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

#Remove Appx
Get-AppxPackage *WinRAR* | Remove-AppxPackage
Get-AppxPackage *PlusPlus* | Remove-AppxPackage
Get-AppxPackage *PowerRename* | Remove-AppxPackage
Get-AppxPackage *ImageResizer* | Remove-AppxPackage

If (Test-Admin) {

	#Remove Appx Installers
	Remove-Item "C:\Program Files\Notepad++\contextMenu\NppShell.msix" -Force -ErrorAction Ignore
	Remove-Item "C:\Program Files\PowerToys\modules\PowerRename\PowerRenameContextMenuPackage.msix" -Force -ErrorAction Ignore
	Remove-Item "C:\Program Files\PowerToys\modules\ImageResizer\ImageResizerContextMenuPackage.msix" -Force -ErrorAction Ignore
	Remove-Item "C:\Program Files\WinRAR\RarExtPackage.msix" -Force -ErrorAction Ignore

}