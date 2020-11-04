<#
.DESCRIPTION
    Allows the user to adjust the luma, black, chroma, and hue like a proc amp
    This script is set up to work like a DPS-290 Proc amp, where each value can be between -128 and 128, with 0 being the unchanged amount.
.PARAMETER h
    display this help
.PARAMETER p
    previews in FFplay
.PARAMETER s
    saves to file with FFmpeg
.PARAMETER video
    path to the first video
.PARAMETER luma
    adjusts the luma/contrast. [default: 0]
.PARAMETER black
    adjusts the black/brightness. [default: 0]
.PARAMETER chroma
    adjusts the chroma/saturation. [default: 0]
.PARAMETER hue
    adjusts the hue/color. [default: 0]
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
    [System.IO.FileInfo]$video,

    [Parameter(Position=1, ParameterSetName="Run")]
    [ValidateRange(-128, 128)]
    [Int]
    $luma = 0,

    [Parameter(Position=2, ParameterSetName="Run")]
    [ValidateRange(-128, 128)]
    [Int]
    $black = 0,

    [Parameter(Position=3, ParameterSetName="Run")]
    [ValidateRange(-128, 128)]
    [Int]
    $chroma = 0,

    [Parameter(Position=4, ParameterSetName="Run")]
    [ValidateRange(-128, 128)]
    [Int]
    $hue = 0
)


# Display help

if (($h) -or ($PSBoundParameters.Values.Count -eq 0 -and $args.count -eq 0)){
    Get-Help $MyInvocation.MyCommand.Definition -detailed
    if (!$video) {
        exit
    }
}


# Create filter string

if ($luma -lt 1) {
    $luma_temp = [Math]::Round($luma*0.0078125, 4)
}
else {
    $luma_temp = [Math]::Round($luma*0.015625, 4)
}
$luma_ffmpeg = $luma_temp + 1

$black_ffmpeg = [Math]::Round($black*1.40625, 4)

if ($chroma -lt 1) {
    $chroma_temp = [Math]::Round($chroma*0.0078125, 4)
}
else {
    $chroma_temp = [Math]::Round($chroma*0.0703125, 4)
}
$chroma_ffmpeg = $chroma_temp + 1

$hue_ffmpeg = [Math]::Round($hue*1.40625, 4)

$filter = "lutyuv=y=(val+$($black_ffmpeg))*$($luma_ffmpeg):u=val:v=val,hue=h=$($hue_ffmpeg):s=$($chroma_ffmpeg)"


# Run command

if ($p) {
    $tempFile = New-TemporaryFile
    ffmpeg.exe -hide_banner -stats -y -i $video -c:v prores -profile:v 3 -filter_complex $filter -f matroska $tempFile
    ffplay.exe $tempFile
    
    Write-Host "`n`n*******START FFPLAY COMMANDS*******`n"
    Write-Host "ffmpeg.exe -hide_banner -stats -y -i $video -c:v prores -profile:v 3 -filter_complex `"$($filter)`" -f matroska $tempFile`n"
    Write-Host "ffplay $tempFile.FullName`n"
    Write-Host "`n********END FFPLAY COMMANDS********`n`n"
}
else {
    ffmpeg.exe -hide_banner -i $video -c:v prores -profile:v 3 -filter_complex $filter "$((Get-Item $video).Basename)_procamp.mov"

    Write-Host "`n`n*******START FFMPEG COMMANDS*******`n"
    Write-Host "ffmpeg.exe -hide_banner -i $video -c:v prores -profile:v 3 -filter_complex `"$($filter)`" `"$((Get-Item $video).Basename)_procamp.mov`"`n"
    Write-Host "`n********END FFMPEG COMMANDS********`n`n"
}
