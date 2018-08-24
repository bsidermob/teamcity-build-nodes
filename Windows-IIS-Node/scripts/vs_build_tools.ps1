# Download MS Build Tools Bootstrapper
$url = "https://aka.ms/vs/15/release/vs_buildtools.exe"
$output = "C:\Users\Administrator\Downloads\vs_buildtools.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Install VisualStudio components
# List of all component IDs is here:
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools
cmd /c $output --quiet --wait --norestart `
--add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
--add Microsoft.VisualStudio.Workload.NetCoreBuildTools `
--add Microsoft.VisualStudio.Workload.WebBuildTools `
--add Microsoft.VisualStudio.Workload.NodeBuildTools `
--add Microsoft.VisualStudio.Workload.MSBuildTools `
--add Microsoft.VisualStudio.Workload.NetCoreBuildTools `
--includeOptional
