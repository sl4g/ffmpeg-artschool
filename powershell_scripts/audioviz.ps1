<#
.DESCRIPTION
    creates audio visualization overlay by blending video and audio using displace and showcqt
.PARAMETER h
    display this help
.PARAMETER p
    previews in FFplay
.PARAMETER s
    saves to file with FFmpeg
.PARAMETER input1
    path to the audio file
.PARAMETER input2
    path to the video file
.NOTES
    Audio file must be the first argument, video file must be the second argument
#>


# Parse arguments

Param(
    [Parameter(ParameterSetName="Help")]
    [Parameter(ParameterSetName="Run")]
    [Switch]
    $h,

    [Parameter(ParameterSetName="Run")]
    [Switch]
    $p,

    [Parameter(ParameterSetName="Run")]
    [Switch]
    $s = $true,

    [Parameter(Position=0, Mandatory, ParameterSetName="Run")]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The Path argument must be a file. Folder paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$input1,

    [Parameter(Position=1, Mandatory, ParameterSetName="Run")]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The Path argument must be a file. Folder paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$input2
)


# Display help

if (($h) -or ($PSBoundParameters.Values.Count -eq 0 -and $args.count -eq 0)){
    Get-Help $MyInvocation.MyCommand.Definition -detailed
    if (!$input1) {
        exit
    }
}


# Create filter string

$filter = "color=0x808080:s=720x480,format=rgb24,loop=-1:size=2[base];
   [0:a]showcqt=s=720x480:basefreq=73.41:endfreq=1567.98,format=rgb24,geq='p(X,363)',setsar=1,colorkey=black:similarity=0.1[vcqt];[base][vcqt]overlay,split[vcqt1][vcqt2];[1:v]scale=720x480,format=rgb24,setsar=1[bgv];[bgv][vcqt1][vcqt2]displace=edge=blank,format=yuv420p10le[v]"


# Run command

if ($p) {
    $tempFile = New-TemporaryFile
    ffmpeg.exe -hide_banner -stats -y -i $input1 -i $input2 -c:v prores -profile:v 3 -filter_complex $filter -map "[v]" -map "0:a" -shortest -f matroska $tempFile
    ffplay.exe $tempFile
    
    Write-Host "`n`n*******START FFPLAY COMMANDS*******`n"
    Write-Host "ffmpeg.exe -hide_banner -stats -y -i $input1 -i $input2 -c:v prores -profile:v 3 -filter_complex `"$($filter)`" -map `"[v]`" -map `"0:a`" -shortest -f matroska $tempFile`n"
    Write-Host "ffplay $tempFile.FullName`n"
    Write-Host "`n********END FFPLAY COMMANDS********`n`n"
}
else {
    ffmpeg.exe -hide_banner -i $input1 -i $input2 -c:v prores -profile:v 3 -filter_complex $filter -map "[v]" "$((Get-Item $input1).Basename)_audioviz.mov"

    Write-Host "`n`n*******START FFMPEG COMMANDS*******`n"
    Write-Host "ffmpeg.exe -hide_banner -i $input1 -i $input2 -c:v prores -profile:v 3 -filter_complex `"$($filter)`" -map `"[v]`" `"$((Get-Item $input1).Basename)_audioviz.mov`"`n"
    Write-Host "`n********END FFMPEG COMMANDS********`n`n"
}
