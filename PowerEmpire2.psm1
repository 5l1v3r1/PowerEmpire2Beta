
if (!(Test-Path variable:Global:EmpireSessions ))
{
    $Global:EmpireSessions = New-Object System.Collections.ArrayList
}

function DisableSSLCheck () {
    if ([System.Net.ServicePointManager]::CertificatePolicy.ToString() -ne 'IgnoreCerts')
        {
            $Domain = [AppDomain]::CurrentDomain
            $DynAssembly = New-Object System.Reflection.AssemblyName('IgnoreCerts')
            $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
            $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('IgnoreCerts', $false)
            $TypeBuilder = $ModuleBuilder.DefineType('IgnoreCerts', 'AutoLayout, AnsiClass, Class, Public, BeforeFieldInit', [System.Object], [System.Net.ICertificatePolicy])
            $TypeBuilder.DefineDefaultConstructor('PrivateScope, Public, HideBySig, SpecialName, RTSpecialName') | Out-Null
            $MethodInfo = [System.Net.ICertificatePolicy].GetMethod('CheckValidationResult')
            $MethodBuilder = $TypeBuilder.DefineMethod($MethodInfo.Name, 
                'PrivateScope, 
                Public, 
                Virtual, 
                HideBySig, 
                VtableLayoutMask', 
                $MethodInfo.CallingConvention, 
                $MethodInfo.ReturnType, 
                ([Type[]] ($MethodInfo.GetParameters() | % {$_.ParameterType})))
            $ILGen = $MethodBuilder.GetILGenerator()
            $ILGen.Emit([Reflection.Emit.Opcodes]::Ldc_I4_1)
            $ILGen.Emit([Reflection.Emit.Opcodes]::Ret)
            $TypeBuilder.CreateType() | Out-Null

            # Disable SSL certificate validation
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object IgnoreCerts
        }
}
. $PSScriptRoot\Admin.ps1
. $PSScriptRoot\Session.ps1
. $PSScriptRoot\Listener.ps1
. $PSScriptRoot\Module.ps1
. $PSScriptRoot\Stager.ps1
. $PSScriptRoot\Agents.ps1
. $PSScriptRoot\Report.ps1
