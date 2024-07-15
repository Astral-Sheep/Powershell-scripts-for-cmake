$BuildType = ""
$BuildArch = ""
$AdditionalArgs = @()
$Silent = $false

function PrintMsg($msg)
{
	if ($Silent)
	{
		$null = Write-Output $msg
	}
	else
	{
		Write-Ouput $msg
	}
}

for ($i = 0; $i -lt $args.Length; $i++)
{
	if ($args[$i] -eq "-t" -or $args[$i] -eq "--type")
	{
		if ($BuildType -eq "")
		{
			$BuildType = $args[$i + 1]
		}
		else
		{
			Write-Warning "Build type already specified, ignoring type $($args[$i + 1])"
		}

		$i++
	}
	elseif ($args[$i] -eq "-a" -or $args[$i] -eq "--architecture")
	{
		if ($BuildArch -eq "")
		{
			$BuildArch = $args[$i + 1]
		}
		else
		{
			Write-Warning "Build architecture already specified, ignoring type $($args[$i + 1])"
		}

		$i++
	}
	elseif ($args[$i] -eq "-s" -or $args[$i] -eq "--silent")
	{
		$Silent = $true
	}
	else
	{
		$AdditionalArgs += $args[$i]
	}
}

if ($BuildType -eq "")
{
	$BuildType = "Debug"
}

if ($BuildArch -eq "")
{
	$BuildArch = "x64"
}

$CmakeArgA = ""

switch ($BuildArch)
{
	"x64" {
		$CmakeArgA = "x64"; Break
	}
	"64" {
		$BuildArch = "x64"
		$CmakeArgA = "x64"; Break
	}
	"x86" {
		$CmakeArgA = "Win32"; Break
	}
	"86" {
		$BuildArch = "x86"
		$CmakeArgA = "Win32"; Break
	}
	"Win32" {
		$BuildArch = "x86"
		$CmakeArgA = "Win32"; Break
	}
	"32" {
		$BuildArch = "x86"
		$CmakeArgA = "Win32"; Break
	}
	default {
		Write-Warning "Invalid target architecture: $BuildArch. Defaulting to x64"
		$BuildArch = "x64"
		$CmakeArgA = "x64"
	}
}

$BuildPath = ".\bin\$BuildArch\$BuildType"

PrintMsg "-- Architecture: $CmakeArgA"
PrintMsg "-- Type: $BuildType"
PrintMsg "-- Build location: $BuildPath"
PrintMsg "-- Additional arguments: $AdditionalArgs"

if ($Silent)
{
	$null = cmake -G "Visual Studio 16 2019" -A $CmakeArgA -S . -B $BuildPath -DCMAKE_BUILD_TYPE="$BuildType" $AdditionalArgs
	$null = cmake --build $BuildPath
}
else
{
	cmake -G "Visual Studio 16 2019" -A $CmakeArgA -S . -B $BuildPath -DCMAKE_BUILD_TYPE="$BuildType" $AdditionalArgs
	cmake --build $BuildPath
}

