try
{
	cmake . -G Ninja $args
}
catch
{
	throw $_.Exception.Message
	return
}

try
{
	Remove-Item build.ninja
	Remove-Item cmake_install.cmake
	Remove-Item CMakeCache.txt
	Remove-Item CMakeFiles -Recurse

	if (Test-Path -Path .\src)
	{
		if (Test-Path .\src\cmake_install.cmake)
		{
			Remove-Item .\src\cmake_install.cmake
		}

		if (Test-Path .\src\CMakeFiles)
		{
			Remove-Item .\src\CMakeFiles -Recurse
		}

		foreach ($folder in (Get-ChildItem -Path .\src -Recurse -Directory | % { $_.FullName }))
		{
			if (Test-Path $folder\cmake_install.cmake)
			{
				Remove-Item $folder\cmake_install.cmake
			}

			if (Test-Path -Path $folder\CMakeFiles)
			{
				Remove-Item $folder\CMakeFiles -Recurse
			}
		}
	}
}
catch
{
	throw $_.Exception.Message
}

