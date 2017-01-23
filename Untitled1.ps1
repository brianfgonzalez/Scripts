function Enable-Privilege {
 param(
  ## The privilege to adjust. This set is taken from
  ## http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
  [ValidateSet(
   "SeAssignPrimaryTokenPrivilege", "SeAuditPrivilege", "SeBackupPrivilege",
   "SeChangeNotifyPrivilege", "SeCreateGlobalPrivilege", "SeCreatePagefilePrivilege",
   "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeCreateTokenPrivilege",
   "SeDebugPrivilege", "SeEnableDelegationPrivilege", "SeImpersonatePrivilege", "SeIncreaseBasePriorityPrivilege",
   "SeIncreaseQuotaPrivilege", "SeIncreaseWorkingSetPrivilege", "SeLoadDriverPrivilege",
   "SeLockMemoryPrivilege", "SeMachineAccountPrivilege", "SeManageVolumePrivilege",
   "SeProfileSingleProcessPrivilege", "SeRelabelPrivilege", "SeRemoteShutdownPrivilege",
   "SeRestorePrivilege", "SeSecurityPrivilege", "SeShutdownPrivilege", "SeSyncAgentPrivilege",
   "SeSystemEnvironmentPrivilege", "SeSystemProfilePrivilege", "SeSystemtimePrivilege",
   "SeTakeOwnershipPrivilege", "SeTcbPrivilege", "SeTimeZonePrivilege", "SeTrustedCredManAccessPrivilege",
   "SeUndockPrivilege", "SeUnsolicitedInputPrivilege")]
  $Privilege,
  ## The process on which to adjust the privilege. Defaults to the current process.
  $ProcessId = $pid,
  ## Switch to disable the privilege, rather than enable it.
  [Switch] $Disable
 )

 ## Taken from P/Invoke.NET with minor adjustments.
 $definition = @'
 using System;
 using System.Runtime.InteropServices;
  
 public class AdjPriv
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
   ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
  
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }
  
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public static bool EnablePrivilege(long processHandle, string privilege, bool disable)
  {
   bool retVal;
   TokPriv1Luid tp;
   IntPtr hproc = new IntPtr(processHandle);
   IntPtr htok = IntPtr.Zero;
   retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
   tp.Count = 1;
   tp.Luid = 0;
   if(disable)
   {
    tp.Attr = SE_PRIVILEGE_DISABLED;
   }
   else
   {
    tp.Attr = SE_PRIVILEGE_ENABLED;
   }
   retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
   retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
   return retVal;
  }
 }
'@

 $processHandle = (Get-Process -id $ProcessId).Handle
 $type = Add-Type $definition -PassThru
 $type[0]::EnablePrivilege($processHandle, $Privilege, $Disable)
}

Enable-Privilege SeTakeOwnershipPrivilege
<#
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SAM\SAM",`
[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)

# You must get a blank acl for the key b/c you do not currently have access
$acl = $key.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
$me = [System.Security.Principal.NTAccount]"$env:COMPUTERNAME\$env:USERNAME"
$acl.SetOwner($me)
$key.SetAccessControl($acl)

# After you have set owner you need to get the acl with the perms so you can modify it.
$acl = $key.GetAccessControl()
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($me,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

$key.Close()
#>

# get the username of the current user
$oCurrentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
# create an identity reference for the owner
$oCurrentUser = new-object System.Security.Principal.NTAccount($oCurrentUserName)

$oIdentityReference = [System.Security.Principal.NTAccount]("$env:COMPUTERNAME\$env:USERNAME")
# Rights to assign. List: http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights(v=vs.110).aspx
$oRegistryRights = [System.Security.AccessControl.RegistryRights]::FullControl
# Permission inheritance: None, ContainerInherit, Object Inherit
$oInheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::None
# Propagation of permissions: None, InheritOnly, NoPropagateInherit
$oPropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
$oAccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
$oRule = New-Object System.Security.AccessControl.RegistryAccessRule ($oIdentityReference, $oRegistryRights, $oInheritanceFlags, $oPropagationFlags, $oAccessControlType)
# Alternatively, create your rule list manually:
$AclRuleList = New-Object System.Security.AccessControl.RegistrySecurity
$AclRuleList.AddAccessRule($oRule)
$AclRuleList.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$AclRuleList.SetAccessRuleProtection($true,$false)

Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\*\FxProperties' | `
  ? { $_.Property -contains '{E0A941A0-88A2-4df5-8D6B-DD20BB06E8FB},4' } | `
  % {
    $oPermission = New-Object System.Security.AccessControl.RegistryAccessRule("BUILTIN\Administrators","FullControl","Allow")
    $oAccessControl = $_.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
    $oAccessControl.SetOwner($oCurrentUser)
    #$_.Close()
    $_.SetAccessControl($AclRuleList)
    #$_.SetValue('TestName', '1', [Microsoft.Win32.RegistryValueKind]::DWORD)
  }