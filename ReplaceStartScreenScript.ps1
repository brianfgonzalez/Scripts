#----------------------------------------------
#region Application Functions
#----------------------------------------------
function OnApplicationLoad {
 #Note: This function is not called in Projects
 #Note: This function runs before the form is created
 #Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
 #Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
 #Important: Form controls cannot be accessed in this function
 #TODO: Add snapins and custom code to validate the application load
 
 return $true #return true for success or false for failure
}
function OnApplicationExit {
 #Note: This function is not called in Projects
 #Note: This function runs after the form is closed
 #TODO: Add custom code to clean up and unload snapins when the application exits
 
 $script:ExitCode = 0 #Set the exit code for the Packager
}
#endregion Application Functions
#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-test_pff {
 #----------------------------------------------
 #region Import the Assemblies
 #----------------------------------------------
 [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
 [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
 [void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
 #endregion Import Assemblies
 #----------------------------------------------
 #region Generated Form Objects
 #----------------------------------------------
 [System.Windows.Forms.Application]::EnableVisualStyles()
 $form1 = New-Object System.Windows.Forms.Form
 $radiobutton5 = New-Object System.Windows.Forms.RadioButton
 $radiobutton4 = New-Object System.Windows.Forms.RadioButton
 $groupbox1 = New-Object System.Windows.Forms.GroupBox
 $verizonbutton = New-Object System.Windows.Forms.RadioButton
 $attbutton2 = New-Object System.Windows.Forms.RadioButton
 $sprintbutton3 = New-Object System.Windows.Forms.RadioButton
 $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
 #endregion Generated Form Objects
 #----------------------------------------------
 # User Generated Script
 #----------------------------------------------
 $FormEvent_Load={
 #TODO: Initialize Form Controls here
 
 }
 
 # --End User Generated Script--
 #----------------------------------------------
 # Generated Events
 #----------------------------------------------
 
 $Form_StateCorrection_Load=
 {
 #Correct the initial state of the form to prevent the .Net maximized form issue
 $form1.WindowState = $InitialFormWindowState
 }
 #----------------------------------------------
 #region Generated Form Code
 #----------------------------------------------
 #
 # form1
 #
 $form1.Controls.Add($radiobutton5)
 $form1.Controls.Add($radiobutton4)
 $form1.Controls.Add($groupbox1)
 $form1.ClientSize = New-Object System.Drawing.Size(442,370)
 $form1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $form1.Name = "form1"
 $form1.Text = "Form"
 $form1.add_Load($FormEvent_Load)
 #
 # radiobutton5
 #
 $radiobutton5.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $radiobutton5.Location = New-Object System.Drawing.Point(245,60)
 $radiobutton5.Name = "radiobutton5"
 $radiobutton5.Size = New-Object System.Drawing.Size(104,24)
 $radiobutton5.TabIndex = 2
 $radiobutton5.TabStop = $True
 $radiobutton5.Text = "radiobutton5"
 $radiobutton5.UseVisualStyleBackColor = $True
 #
 # radiobutton4
 #
 $radiobutton4.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $radiobutton4.Location = New-Object System.Drawing.Point(90,50)
 $radiobutton4.Name = "radiobutton4"
 $radiobutton4.Size = New-Object System.Drawing.Size(104,24)
 $radiobutton4.TabIndex = 1
 $radiobutton4.TabStop = $True
 $radiobutton4.Text = "radiobutton4"
 $radiobutton4.UseVisualStyleBackColor = $True
 #
 # groupbox1
 #
 $groupbox1.Controls.Add($radiobutton3)
 $groupbox1.Controls.Add($radiobutton2)
 $groupbox1.Controls.Add($radiobutton1)
 $groupbox1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $groupbox1.Location = New-Object System.Drawing.Point(25,100)
 $groupbox1.Name = "groupbox1"
 $groupbox1.Size = New-Object System.Drawing.Size(385,255)
 $groupbox1.TabIndex = 0
 $groupbox1.TabStop = $False
 $groupbox1.Text = "groupbox1"
 #
 # radiobutton3
 #
 $radiobutton3.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $radiobutton3.Location = New-Object System.Drawing.Point(145,120)
 $radiobutton3.Name = "radiobutton3"
 $radiobutton3.Size = New-Object System.Drawing.Size(104,24)
 $radiobutton3.TabIndex = 2
 $radiobutton3.TabStop = $True
 $radiobutton3.Text = "radiobutton3"
 $radiobutton3.UseVisualStyleBackColor = $True
 #
 # radiobutton2
 #
 $radiobutton2.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $radiobutton2.Location = New-Object System.Drawing.Point(100,75)
 $radiobutton2.Name = "radiobutton2"
 $radiobutton2.Size = New-Object System.Drawing.Size(104,24)
 $radiobutton2.TabIndex = 1
 $radiobutton2.TabStop = $True
 $radiobutton2.Text = "radiobutton2"
 $radiobutton2.UseVisualStyleBackColor = $True
 #
 # radiobutton1
 #
 $radiobutton1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
 $radiobutton1.Location = New-Object System.Drawing.Point(60,40)
 $radiobutton1.Name = "radiobutton1"
 $radiobutton1.Size = New-Object System.Drawing.Size(104,24)
 $radiobutton1.TabIndex = 0
 $radiobutton1.TabStop = $True
 $radiobutton1.Text = "radiobutton1"
 $radiobutton1.UseVisualStyleBackColor = $True
 #endregion Generated Form Code
 #----------------------------------------------
 #Save the initial state of the form
 $InitialFormWindowState = $form1.WindowState
 #Init the OnLoad event to correct the initial state of the form
 $form1.add_Load($Form_StateCorrection_Load)
 #Show the Form
 return $form1.ShowDialog()
} #End Function
#Call OnApplicationLoad to initialize
if(OnApplicationLoad -eq $true)
{
 #Create the form
 Call-test_pff | Out-Null
 #Perform cleanup
 OnApplicationExit
}