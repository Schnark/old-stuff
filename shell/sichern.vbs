'Script zur Datensicherung auf USB-Stick

Option Explicit

Dim FSO
Set FSO = WScript.CreateObject("Scripting.FileSystemObject")
Dim usblauf
usblauf=InputBox("USB-Laufwerk: ","Sichern","H:\")
Dim ordnerneu, neudatei, dateiakt
ordnerneu = 0
neudatei = 0
dateiakt = 0

Dim vertrauen
vertrauen = MsgBox("Soll der Pfadumwandlung vertraut werden?",4+32,"Sichern")

Call sichern(InputBox("Zu sichernder Pfad: ","Sichern","D:\"))
MsgBox "Bei der Sicherung wurden " & ordnerneu & " Verzeichniss(e)" & vbCrLf & "neu angelegt, " & neudatei & " Datei(en) zum ersten Mal" & vbCrLf & "gesichert und " & dateiakt & " Datei(en) aktualisiert.",64,"Sichern"

Function USB ( verz )
'Ermittelt das USB-Verzeichnis
  Dim usbverz, pos
  usbverz=usblauf & "Sicherung" & right(verz,len(verz)-2)
  pos = instr(usbverz,"Eigene ")
  If pos > 0 Then usbverz = left(usbverz, pos-1) & right(usbverz, len(usbverz)-pos-6) End If
  If vertrauen = 6 Then
     USB = usbverz
  Else
     USB = InputBox("USB-Verzeichnis zu " & verz & ": ","Verzeichnis",usbverz)
  End If
End Function

Function verzneu ( verz, usbverz )
'Ermittelt, ob Verzeichnis neu angelegt werden muss/soll
  verzneu = 1
  If not FSO.FolderExists(usbverz) Then
     If LCase(Right(verz,8))="recycler" Then verzneu = 0 End If
     If LCase(Right(verz,25))="system volume information" Then verzneu = 0 End If
     If LCase(Right(verz,22))="taschenbuch der physik" Then verzneu = 0 End If
     If LCase(Right(verz,17))="user\eigene musik" Then verzneu = 0 End If
     If LCase(Right(verz,19))="konrad\eigene musik" Then verzneu = 0 End If
     If LCase(Right(verz,21))="christel\eigene musik" Then verzneu = 0 End If
     If LCase(Right(verz,31))="gemeinsame dateien\eigene musik" Then verzneu = 0 End If
     If LCase(Right(verz,18))="user\eigene videos" Then verzneu = 0 End If
     If LCase(Right(verz,20))="konrad\eigene videos" Then verzneu = 0 End If
     If LCase(Right(verz,22))="christel\eigene videos" Then verzneu = 0 End If
     If LCase(Right(verz,32))="gemeinsame dateien\eigene videos" Then verzneu = 0 End If
     If verzneu=1 Then
        If MsgBox("Verzeichnis " & usbverz & " zum Sichern von " & verz & " neu anlegen?", 4+32, "Sichern") = 6 Then
           FSO.CreateFolder(usbverz)
           ordnerneu = ordnerneu + 1
        Else
           verzneu = 0
        End If
     End If
  End If
End Function

Function dateineu ( verz, datei )
'Ermittelt, ob Datei neu angelegt werden muss/soll
  dateineu = 0
  If LCase(datei) = "thumbs.db" Then Exit Function End If
  If LCase(datei) = "desktop.ini" Then Exit Function End If
  If LCase(datei) = "spider.sav" Then Exit Function End If
  If LCase(datei) = "beispielbilder.lnk" Then Exit Function End If
  If LCase(Right(datei,4))=".aux" Then Exit Function End If
  If LCase(Right(datei,4))=".log" Then Exit Function End If
  If LCase(Right(datei,4))=".dvi" Then Exit Function End If
  If LCase(Right(datei,4))=".out" Then Exit Function End If
  If LCase(Right(datei,4))=".bkf" Then Exit Function End If
  If MsgBox("Datei '" & datei & "' in " & verz & " neu sichern?", 4+32, "Sichern") = 6 Then dateineu = 1 End If
End Function

Sub sichern ( verz )
'Sichert ein Verzeichnis
  Dim usbverz, von, nach, datei, ordner
  usbverz = USB (verz)
  If verzneu (verz, usbverz) = 0 Then Exit Sub End If
  Set von = FSO.GetFolder(verz)
  Set nach = FSO.GetFolder(usbverz)
  For Each datei in von.Files
      If FSO.FileExists(usbverz & "\" & datei.Name) Then
         If DateDiff("h",FSO.GetFile(usbverz & "\" & datei.Name).DateLastModified,datei.DateLastModified) > 0 Then
            datei.copy nach.path&"\"
            dateiakt = dateiakt + 1 
         End If
      Else
         If dateineu(verz, datei.Name) = 1 Then
            datei.copy nach.path&"\"
            neudatei = neudatei + 1
         End If
      End If
  Next
  For Each ordner in von.SubFolders
      sichern(ordner.Path)
  Next
End Sub