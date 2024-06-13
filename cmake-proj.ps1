$projectName = ""
$outputType = ""

function NewItem($path)
{
	$null = New-Item $path
	Write-Output "-- New item: $path"
}

function NewDir($path)
{
	$null = mkdir $path
	Write-Output "-- New directory: $path"
}

for ($i = 0; $i -lt $args.Length; $i++)
{
	if ($args[$i] -eq "-n" -or $args[$i] -eq "--name")
	{
		if ($projectName -eq "")
		{
			if ($i + 1 -lt $args.Length)
			{
				$projectName = $args[$i + 1]
			}
			else
			{
				Write-Warning "Missing argument for $($args[$i]), ignoring argument"
			}
		}
		else
		{
			Write-Warning "Project name already set, ignoring argument"
		}

		$i++
	}
	elseif ($args[$i] -eq "-o" -or $args[$i] -eq "--output")
	{
		if ($outputType -eq "")
		{
			if ($i + 1 -lt $args.Length)
			{
				$outputType = $args[$i + 1]
			}
			else
			{
				Write-Warning "Missing argument for $($args[$i]), ignoring argument"
			}
		}
		else
		{
			Write-Warning "Output type already set, ignoring argument"
		}
	}
}

if ($projectName -eq "")
{
	Write-Output "No project name set, defaulting to 'New Project'"
	$projectName = "NewProject"
}

if ($outputType -eq "")
{
	Write-Output "No output type set, defaulting to executable"
	$outputType = "exe"
}

# Project directory
if (-not (Test-Path .\$projectName))
{
	NewDir .\$projectName
}

# Source directory
if (-not (Test-Path .\$projectName\src))
{
	NewDir .\$projectName\src
}

# Dependencies directory
if (-not (Test-Path .\$projectName\dependencies))
{
	NewDir .\$projectName\dependencies
}

# CMakeLists
if ($outputType -eq "lib")
{
	$projectAdd = @"
if (BUILD_SHARED_LIBS)
	add_library(`${PROJECT_NAME} SHARED)
	target_compile_definitions(`${PROJECT_NAME}` PRIVATE EXPORT)
else()
	add_library(`${PROJECT_NAME} STATIC)
endif()

"@

	if (-not (Test-Path .\$projectName\lib))
	{
		NewDir .\$projectName\lib
	}

	if (-not (Test-Path .\$projectName\include))
	{
		NewDir .\$projectName\include
	}

	if (-not (Test-Path .\$projectName\build.ps1))
	{
		NewItem .\$projectName\build.ps1
		(Get-Content C:\powershell\cmake\build_lib) -replace "{PROJECT}", $projectName | Set-Content .\$projectName\build.ps1
	}
}
else
{
	$projectAdd = "add_executable(`${PROJECT_NAME} src/Main.cpp)"

	if (-not (Test-Path -Path .\$projectName\src\Main.cpp))
	{
		NewItem .\$projectName\src\Main.cpp
		Add-Content .\$projectName\src\Main.cpp @"
#include <iostream>

int main()
{
	std::cout << "Hello world!" << std::endl;
	return 0;
}

"@
	}

	if (-not (Test-Path .\$projectName\build.ps1))
	{
		NewItem .\$projectName\build.ps1
		(Get-Content C:\powershell\cmake\build_exe) -replace "{PROJECT}", $projectName | Set-Content .\$projectName\build.ps1
	}
}

if (-not (Test-Path -Path .\$projectName\CMakeLists.txt))
{
	NewItem .\$projectName\CMakeLists.txt
	Add-Content .\$projectName\CMakeLists.txt @"
cmake_minimum_required(VERSION 3.15)
project($projectName VERSION 1.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

$projectAdd
add_subdirectory(src)

set(CMAKE_EXE_LINKER_FLAGS "`${CMAKE_EXE_LINKER_FLAGS} /ignore:4099")
set(CMAKE_SHARED_LINKER_FLAGS "`${CMAKE_SHARED_LINKER_FLAGS} /ignore:4099")
set(CMAKE_STATIC_LINKER_FLAGS "`${CMAKE_STATIC_LINKER_FLAGS} /ignore:4099")

"@
}

if (-not (Test-Path -Path .\$projectName\src\CMakeLists.txt))
{
	NewItem .\$projectName\src\CMakeLists.txt
	Add-Content .\$projectName\src\CMakeLists.txt @"
target_sources(`${PROJECT_NAME} PRIVATE$(if ($outputType -eq "lib") { "" } else { "`r`n`tMain.cpp" })
)

target_include_directories(`${PROJECT_NAME} PRIVATE
	`${CMAKE_CURRENT_SOURCE_DIR}
)

"@
}

