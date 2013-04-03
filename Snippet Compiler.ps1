$def = (gci $MyInvocation.MyCommand.Name).Directory.ToString()

#################################################################################################

$mnuAtom_Click= {
  if ($txtEdit.Text -ne "") {
    $res = [Windows.Forms.MessageBox]::Show("Do you want to save data before?", `
                 $frmMain.Text, [Windows.Forms.MessageBoxButtons]::YesNoCancel, `
                                        [Windows.Forms.MessageBoxIcon]::Question)
    switch ($res) {
      'Yes'    {
        (New-Object Windows.Forms.SaveFileDialog) | % {
          $_.FileName = "source"
          $_.Filter = "C# (*.cs)|*.cs"
          $_.InitialDirectory = $def

          if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
            Out-File $_.FileName -enc UTF8 -input $txtEdit.Text
          }
        }
        break
      }
      'No'     { $txtEdit.Clear(); break; }
      'Cancel' { return }
    }
  }#if
}

$mnuOpen_Click= {
  (New-Object Windows.Forms.OpenFileDialog) | % {
    $_.FileName = "source"
    $_.Filter = "C# (*.cs)|*.cs"
    $_.InitialDirectory = $def

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $sr = New-Object IO.StreamReader $_.FileName
      $txtEdit.Text = $sr.ReadToEnd()
      $sr.Close()
    }
  }
}

$mnuFont_Click= {
  (New-Object Windows.Forms.FontDialog) | % {
    $_.Font = "Lucida Console"
    $_.MinSize = 10
    $_.MaxSize = 12
    $_.ShowEffects = $false

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $txtEdit.Font = $_.Font
    }
  }
}

$mnuWrap_Click= {
  $toggle =! $mnuWrap.Checked
  $mnuWrap.Checked = $toggle
  $txtEdit.WordWrap = $toggle
}

$mnuToS1_Click= {
  switch ($mnuToS1.Checked) {
    $true  { $mnuToS1.Checked = $false; $scSplt1.Panel2Collapsed = $true; break }
    $false { $mnuToS1.Checked = $true; $scSplt1.Panel2Collapsed = $false; break }
  }
}

$mnuToS2_Click= {
  switch ($mnuToS2.Checked) {
    $true  { $mnuToS2.Checked = $false; $scSplt2.Panel2Collapsed = $true; break }
    $false { $mnuToS2.Checked = $true; $scSplt2.Panel2Collapsed = $false; break }
  }
}

$mnuSBar_Click= {
  $toggle =! $mnuSbar.Checked
  $mnuSBar.Checked = $toggle
  $sbPanel.Visible = $toggle
}

$mnuBnRA_Click= {
  Invoke-Builder
  if ($script:make.Errors.Count -eq 0) { Invoke-Item $txtIOut.Text }
}

$chkExec_Click= {
  switch ($chkExec.Checked) {
    $true  {
      $txtIOut.Text = $def + '\app.exe'
      $chkWApp.Enabled = $true
      $chkIMem.Enabled = $false
      $mnuBnRA.Enabled = $true
      break
    }
    $false {
      $txtIOut.Text = $def + '\lib.dll'
      $chkWApp.Enabled = $false
      $chkImem.Enabled = $true
      $mnuBnRA.Enabled = $false
      break
    }
  }#switch
}

$chkWApp_Click= {
  switch ($chkWApp.Checked) {
    $true  {
      $lboRefs.Items.AddRange(@("`"System.Drawing.dll`"", "`"System.Windows.Forms.dll`""))
      break
    }
    $false {
      $lboRefs.Items.Remove("`"System.Windows.Forms.dll`"")
      $lboRefs.Items.Remove("`"System.Drawing.dll`"")
      break
    }
  }#switch
}

$btnRAdd_Click= {
  (New-Object Windows.Forms.OpenFileDialog) | % {
    $_.Filter = "PE File (*.dll)|*.dll"
    $_.InitialDirectory = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $lboRefs.Items.Add('"' + (Split-Path -leaf $_.FileName) + '"')
    }
  }
}

$frmMain_Load= {
  $txtIOut.Text = $def + '\app.exe'
  $sbPnl_2.Text = "Str: 1, Col: 0"
  $lboRefs.Items.AddRange(@("`"System.dll`"", "`"System.Core.dll`""))
}

#################################################################################################

function Invoke-Builder {
  $lstView.Items.Clear()

  if ($txtEdit.Text -ne "") { 
    $cdcp.GenerateExecutable = $chkExec.Checked

    if ($chkWApp.Checked) { $cdcp.CompilerOptions = "/t:winexe" }

    $cdcp.IncludeDebugInformation = $chkIDbg.Checked
    $cdcp.GenerateInMemory = $chkImem.Checked

    if ($lboRefs.Items.Count -ne 0) {
      for ($i = 0; $i -lt $lboRefs.Items.Count; $i++) {
        $cdcp.ReferencedAssemblies.Add($lboRefs.Items[$i].ToString())
      }
    }

    $cdcp.WarningLevel = 3
    $cdcp.OutputAssembly = $txtIOut.Text

    $script:make = $cscp.CompileAssemblyFromSource($cdcp, $txtEdit.Text)
    $make.Errors | % {
      if (!($_.IsWarning)) { $lstView.ForeColor = [Drawing.Color]::Crimson }
      else { $lstView.ForeColor = [Drawing.Color]::Gray }

      if ($_.Line -ne 0 -and $_.Column -ne 0) {
        $itm = $lstView.Items.Add($_.Line.ToString() + ', ' + ($_.Column - 1).ToString())
      }
      elseif ($_.Line -ne 0 -and $_.Column -eq 0) {
        $itm = $lstView.Items.Add($_.Line.ToString() + ', 0')
      }
      elseif ($_.Line -eq 0 -and $_.Column -eq 0) {
        $itm = $lstView.Items.Add('*')
      }
      $itm.SubItems.Add($_.ErrorNumber)
      $itm.SubItems.Add($_.ErrorText)
    }
  }#if
}

function Get-CursorPoint {
  $z = $txtEdit.SelectionStart
  $y = $txtEdit.GetLineFromCharIndex($z) + 1
  $x = $z - $txtEdit.GetFirstCharIndexOfCurrentLine()

  return (New-Object Drawing.Point($x, $y))
}

function Write-CursorPoint {
  $sbPnl_2.Text = 'Str: ' + (Get-CursorPoint).Y.ToString() + ', Col: ' + `
                                            (Get-CursorPoint).X.ToString()
}

#################################################################################################

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()

  $dict = New-Object "Collections.Generic.Dictionary[String, String]"
  $dict.Add("CompilerVersion", "v3.5")

  $cscp = New-Object Microsoft.CSharp.CSharpCodeProvider($dict)
  $cdcp = New-Object CodeDom.Compiler.CompilerParameters

  $ico = [Drawing.Icon]::ExtractAssociatedIcon($($PSHome + '\powershell_ise.exe'))

  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MainMenu
  $mnuFile = New-Object Windows.Forms.MenuItem
  $mnuAtom = New-Object Windows.Forms.MenuItem
  $mnuOpen = New-Object Windows.Forms.MenuItem
  $mnuEmp1 = New-Object Windows.Forms.MenuItem
  $mnuExit = New-Object Windows.Forms.MenuItem
  $mnuEdit = New-Object Windows.Forms.MenuItem
  $mnuUndo = New-Object Windows.Forms.MenuItem
  $mnuEmp2 = New-Object Windows.Forms.MenuItem
  $mnuCopy = New-Object Windows.Forms.MenuItem
  $mnuPast = New-Object Windows.Forms.MenuItem
  $mnuICut = New-Object Windows.Forms.MenuItem
  $mnuEmp3 = New-Object Windows.Forms.MenuItem
  $mnuSAll = New-Object Windows.Forms.MenuItem
  $mnuView = New-Object Windows.Forms.MenuItem
  $mnuFont = New-Object Windows.Forms.MenuItem
  $mnuTgls = New-Object Windows.Forms.MenuItem
  $mnuWrap = New-Object Windows.Forms.MenuItem
  $mnuToS1 = New-Object Windows.Forms.MenuItem
  $mnuToS2 = New-Object Windows.Forms.MenuItem
  $mnuSBar = New-Object Windows.Forms.MenuItem
  $mnuMake = New-Object Windows.Forms.MenuItem
  $mnuBAsm = New-Object Windows.Forms.MenuItem
  $mnuBnRA = New-Object Windows.Forms.MenuItem
  $mnuHelp = New-Object Windows.Forms.MenuItem
  $mnuInfo = New-Object Windows.Forms.MenuItem
  $scSplt1 = New-Object Windows.Forms.SplitContainer
  $scSplt2 = New-Object Windows.Forms.SplitContainer
  $lstView = New-Object Windows.Forms.ListView
  $chPoint = New-Object Windows.Forms.ColumnHeader
  $chError = New-Object Windows.Forms.ColumnHeader
  $chCause = New-Object Windows.Forms.ColumnHeader
  $txtEdit = New-Object Windows.Forms.TextBox
  $lblLab1 = New-Object Windows.Forms.Label
  $txtIOut = New-Object Windows.Forms.TextBox
  $gboMake = New-Object Windows.Forms.GroupBox
  $chkExec = New-Object Windows.Forms.CheckBox
  $chkWApp = New-Object Windows.Forms.CheckBox
  $chkIDbg = New-Object Windows.Forms.CheckBox
  $chkIMem = New-Object Windows.Forms.CheckBox
  $lblLab2 = New-Object Windows.Forms.Label
  $lboRefs = New-Object Windows.Forms.ListBox
  $btnRAdd = New-Object Windows.Forms.Button
  $sbPanel = New-Object Windows.Forms.StatusBar
  $sbPnl_1 = New-Object Windows.Forms.StatusBarPanel
  $sbPnl_2 = New-Object Windows.Forms.StatusBarPanel
  $mnuRefs = New-Object Windows.Forms.ContextMenu
  $mnuMove = New-Object Windows.Forms.MenuItem
  #
  #mnuMain
  #
  $mnuMain.MenuItems.AddRange(@($mnuFile, $mnuEdit, $mnuView, $mnuMake, $mnuHelp))
  #
  #mnuFile
  #
  $mnuFile.MenuItems.AddRange(@($mnuAtom, $mnuOpen, $mnuEmp1, $mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuAtom
  #
  $mnuAtom.Shortcut = "F3"
  $mnuAtom.Text = "Nu&Clear..."
  $mnuAtom.Add_Click($mnuAtom_Click)
  #
  #mnuOpen
  #
  $mnuOpen.Shortcut = "CtrlO"
  $mnuOpen.Text = "&Open"
  $mnuOpen.Add_Click($mnuOpen_Click)
  #
  #mnuEmp1
  #
  $mnuEmp1.Text = "-"
  #
  #mnuExit
  #
  $mnuExit.Shortcut = "CtrlX"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuEdit
  #
  $mnuEdit.MenuItems.AddRange(@($mnuUndo, $mnuEmp2, $mnuCopy, $mnuPast, `
                                           $mnuICut, $mnuEmp3, $mnuSAll))
  $mnuEdit.Text = "&Edit"
  #
  #mnuUndo
  #
  $mnuUndo.Shortcut = "CtrlZ"
  $mnuUndo.Text = "&Undo"
  $mnuUndo.Add_Click({$txtEdit.Undo()})
  #
  #mnuEmp2
  #
  $mnuEmp2.Text = "-"
  #
  #mnuCopy
  #
  $mnuCopy.Shortcut = "CtrlC"
  $mnuCopy.Text = "&Copy"
  $mnuCopy.Add_Click({if ($txtEdit.SelectionLength -ge 0) {$txtEdit.Copy()}})
  #
  #mnuPast
  #
  $mnuPast.Shortcut = "CtrlV"
  $mnuPast.Text = "&Paste"
  $mnuPast.Add_Click({$txtEdit.Paste()})
  #
  #mnuICut
  #
  $mnuICut.Shortcut = "Del"
  $mnuICut.Text = "Cut &Item"
  $mnuICut.Add_Click({if ($txtEdit.SelectedText -ne "") {$txtEdit.Cut()}})
  #
  #mnuEmp3
  #
  $mnuEmp3.Text = "-"
  #
  #mnuSAll
  #
  $mnuSAll.Shortcut = "CtrlA"
  $mnuSAll.Text = "Select &All"
  $mnuSAll.Add_Click({$txtEdit.SelectAll()})
  #
  #mnuView
  #
  $mnuView.MenuItems.AddRange(@($mnuFont, $mnuTgls))
  $mnuView.Text = "&View"
  #
  #mnuFont
  #
  $mnuFont.Text = "Font..."
  $mnuFont.Add_Click($mnuFont_Click)
  #
  #mnuTgls
  #
  $mnuTgls.MenuItems.AddRange(@($mnuWrap, $mnuToS1, $mnuToS2, $mnuSBar))
  $mnuTgls.Text = "&Toggles"
  #
  #mnuWrap
  #
  $mnuWrap.Checked = $true
  $mnuWrap.Shortcut = "CtrlW"
  $mnuWrap.Text = "&Wrap Mode"
  $mnuWrap.Add_Click($mnuWrap_Click)
  #
  #mnuToS1
  #
  $mnuToS1.Checked = $true
  $mnuToS1.Text = "Building &Progress..."
  $mnuToS1.Add_Click($mnuToS1_Click)
  #
  #mnuToS2
  #
  $mnuToS2.Shortcut = "F12"
  $mnuToS2.Text = "Building P&roperties"
  $mnuToS2.Add_Click($mnuToS2_Click)
  #
  #mnuSBar
  #
  $mnuSBar.Checked = $true
  $mnuSBar.Shortcut = "CtrlB"
  $mnuSBar.Text = "Status &Bar"
  $mnuSBar.Add_Click($mnuSBar_Click)
  #
  #mnuMake
  #
  $mnuMake.MenuItems.AddRange(@($mnuBAsm, $mnuBnRA))
  $mnuMake.Text = "&Build"
  #
  #mnuBAsm
  #
  $mnuBAsm.Shortcut = "F5"
  $mnuBAsm.Text = "&Compile"
  $mnuBAsm.Add_Click({Invoke-Builder})
  #
  #mnuBnRA
  #
  $mnuBnRA.Shortcut = "F9"
  $mnuBnRA.Text = "Compile And &Run"
  $mnuBnRA.Add_Click($mnuBnRA_Click)
  #
  #mnuHelp
  #
  $mnuHelp.MenuItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #scSplt1
  #
  $scSplt1.Dock = "Fill"
  $scSplt1.Orientation = "Horizontal"
  $scSplt1.Panel1.Controls.Add($scSplt2)
  $scSplt1.Panel2.Controls.Add($lstView)
  $scSplt1.SplitterDistance = 100
  $scSplt1.SplitterWidth = 1
  #
  #scSplt2
  #
  $scSplt2.Dock = "Fill"
  $scSplt2.Panel1.Controls.Add($txtEdit)
  $scSplt2.Panel2.Controls.Add($gboMake)
  $scSplt2.Panel2Collapsed = $true
  $scSplt2.SplitterDistance = 100
  $scSplt2.SplitterWidth = 1
  #
  #lstView
  #
  $lstView.Columns.AddRange(@($chPoint, $chError, $chCause))
  $lstView.Dock = "Fill"
  $lstView.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8, [Drawing.FontStyle]::Bold)
  $lstView.FullRowSelect = $true
  $lstView.GridLines = $true
  $lstView.MultiSelect = $false
  $lstView.ShowItemToolTips = $true
  $lstView.View = "Details"
  #
  #chPoint
  #
  $chPoint.Text = "Line"
  $chPoint.Width = 50
  #
  #chError
  #
  $chError.Text = "Error"
  $chError.TextAlign = "Right"
  $chError.Width = 65
  #
  #chCause
  #
  $chCause.Text = "Description"
  $chCause.Width = 650
  #
  #txtEdit
  #
  $txtEdit.AcceptsTab = $true
  $txtEdit.Dock = "Fill"
  $txtEdit.Font = New-Object Drawing.Font("Courier New", 10)
  $txtEdit.Multiline = $true
  $txtEdit.ScrollBars = "Both"
  $txtEdit.Add_Click({Write-CursorPoint})
  $txtEdit.Add_KeyUp({Write-CursorPoint})
  $txtEdit.Add_TextChanged({Write-CursorPoint})
  #
  #gboMake
  #
  $gboMake.Controls.AddRange(@($lblLab1, $txtIOut, $chkExec, $chkWApp, `
                      $chkIDbg, $chkIMem, $lblLab2, $lboRefs, $btnRAdd))
  $gboMake.Dock = "Fill"
  $gboMake.Font = New-Object Drawing.Font("Microsoft Sans Serif", 10)
  $gboMake.Text = "Building Parameters"
  #
  #lblLab1
  #
  $lblLab1.Location = New-Object Drawing.Point(21, 33)
  $lblLab1.Text = "Output:"
  $lblLab1.Width = 50
  #
  #txtIOut
  #
  $txtIOut.Location = New-Object Drawing.Point(71, 31)
  $txtIOut.Width = 163
  #
  #chkExec
  #
  $chkExec.Checked = $true
  $chkExec.Location = New-Object Drawing.Point(23, 63)
  $chkExec.Text = "Create Executable"
  $chkExec.Width = 160
  $chkExec.Add_Click($chkExec_Click)
  #
  #chkWApp
  #
  $chkWApp.Location = New-Object Drawing.Point(43, 83)
  $chkWApp.Text = "WinForm Application"
  $chkWApp.Width = 160
  $chkWApp.Add_Click($chkWApp_Click)
  #
  #chkIDbg
  #
  $chkIDbg.Checked = $true
  $chkIDbg.Location = New-Object Drawing.Point(23, 103)
  $chkIDbg.Text = "Include Debug Information"
  $chkIDbg.Width = 185
  #
  #chkIMem
  #
  $chkIMem.Enabled = $false
  $chkIMem.Location = New-Object Drawing.Point(23, 123)
  $chkIMem.Text = "Build In Memory"
  $chkIMem.Width = 160
  #
  #lblLab2
  #
  $lblLab2.Location = New-Object Drawing.Point(23, 173)
  $lblLab2.Size = New-Object Drawing.Size(79, 17)
  $lblLab2.Text = "References:"
  #
  #lboRefs
  #
  $lboRefs.ContextMenu = $mnuRefs
  $lboRefs.Location = New-Object Drawing.Point(23, 193)
  $lboRefs.SelectionMode = "One"
  $lboRefs.Size = New-Object Drawing.Size(213, 137)
  #
  #btnRAdd
  #
  $btnRAdd.Location = New-Object Drawing.Point(63, 337)
  $btnRAdd.Text = "Add Reference"
  $btnRAdd.Width = 130
  $btnRAdd.Add_Click($btnRAdd_Click)
  #
  #sbPanel
  #
  $sbPanel.Panels.AddRange(@($sbPnl_1, $sbPnl_2))
  $sbPanel.ShowPanels = $true
  $sbPanel.SizingGrip = $false
  #
  #sbPnl_1
  #
  $sbPnl_1.Width = 589
  #
  #sbPnl_2
  #
  $sbPnl_2.Alignment = "Center"
  $sbPnl_2.AutoSize = "Contents"
  #
  #mnuRefs
  #
  $mnuRefs.MenuItems.AddRange(@($mnuMove))
  #
  #mnuMove
  #
  $mnuMove.Shortcut = "Del"
  $mnuMove.Text = "Remove Item"
  $mnuMove.Add_Click({$lboRefs.Items.Remove($lboRefs.SelectedItem)})
  #
  #frmMain
  #
  $frmMain.BackColor = [Drawing.Color]::FromArgb(249, 253, 255)
  $frmMain.ClientSize = New-Object Drawing.Size(790, 550)
  $frmMain.Controls.AddRange(@($scSplt1, $sbPanel))
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.Icon = $ico
  $frmMain.MaximizeBox = $false
  $frmMain.Menu = $mnuMain
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "Snippet Compiler"
  $frmMain.Add_Load($frmMain_Load)

  [void]$frmMain.ShowDialog()
}

#################################################################################################

function frmInfo_Show {
  $frmInfo = New-Object Windows.Forms.Form
  $pbImage = New-Object Windows.Forms.PictureBox
  $lblName = New-Object Windows.Forms.Label
  $lblCopy = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button
  #
  #pbImage
  #
  $pbImage.Location = New-Object Drawing.Point(16, 16)
  $pbImage.Size = New-Object Drawing.Size(32, 32)
  $pbImage.SizeMode = "StretchImage"
  #
  #lblName
  #
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "Snippet Compiler v2.01"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "(C) 2012-2013 greg zakharov gregzakh@gmail.com"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 67)
  $btnExit.Text = "OK"
  #
  #frmInfo
  #
  $frmInfo.AcceptButton = $btnExit
  $frmInfo.CancelButton = $btnExit
  $frmInfo.ClientSize = New-Object Drawing.Size(350, 110)
  $frmInfo.ControlBox = $false
  $frmInfo.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = "CenterScreen"
  $frmInfo.Text = "About..."
  $frmInfo.Add_Load({$pbImage.Image = $ico.ToBitmap()})

  [void]$frmInfo.ShowDialog()
}

#################################################################################################

frmMain_Show