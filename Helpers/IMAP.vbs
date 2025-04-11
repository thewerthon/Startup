Dim i

Call FolderSelect()

Public Sub FolderSelect()
  Dim objOutlook
  Set objOutlook = CreateObject("Outlook.Application")

  Dim F, Folders
  Set F = objOutlook.Session.PickFolder

  If Not F Is Nothing Then
    Dim Result
    Result = MsgBox("Do you want to include the subfolders?", vbYesNo+vbDefaultButton2+vbApplicationModal, "Include Subfolders")

    i = 0
    FixIMAPFolder(F)

    If Result = 6 Then
      Set Folders = F.Folders
      LoopFolders Folders
    End If

    Result = MsgBox("Done!" & vbNewLine & i & " folder(s) have been fixed.", vbInfo, "Fix Imported IMAP Folders")
  
    Set F = Nothing
    Set Folders = Nothing
    Set objOutlook = Nothing
  End If
End Sub

Private Sub LoopFolders(Folders)
  Dim F
  
  For Each F In Folders
    FixIMAPFolder(F)
    LoopFolders F.Folders
  Next
End Sub

Private Sub FixIMAPFolder(F)
  Dim oPA, PropName, Value, FolderType

  PropName = "http://schemas.microsoft.com/mapi/proptag/0x3613001E"
  Value = "IPF.Note"

  On Error Resume Next
  Set oPA = F.PropertyAccessor
  FolderType = oPA.GetProperty(PropName)

  If FolderType = "IPF.Imap" Then
    oPA.SetProperty PropName, Value
    i = i + 1
  End If

  Set oPA = Nothing
End Sub