---
title: Activities and Exercises
layout: default
nav_order: 5
---

# Activities

This document will describe how to run certain scripts for artistic effects!

## Activity 1: Running Bash and FFmpeg

Before we get started with this section, make sure that your terminal window is in the root level of the `ffmpeg-artschool` directory. You can do this by typing `cd` then dragging in the ffmpeg-artschool folder.

Also, for these activities we're going to use ffplay to stream the videos we're creating, rather than save them. In order to do this we're using the following format:

```
ffmpeg -i [InputFile.mov] -c:v prores -filter_complex [Filter String] -f matroska - | ffplay -
```

The last portion that says `-f matroska - | ffplay - ` is telling ffmpeg to output what it's processing as a matroska file, and then telling ffplay to play back whatever it coming out of ffmpeg as it comes out. This means that if your computer can't handle the processing, it might be a bit slow to play back the file. This is why most of our sample files are at 640x480, which is easier for a CPU to handle than a large HD or 2K file.

### Normalizing your source sample_video_files
All of the video files we provide have been normalized to ProRes. However, if you have your own sample files that you want to use, it's best to make sure it's transcoded to ProRes and resized to SD before working with it. We've created a simple bash script that can help you with this. Here's how ton run the script:
```
./bash_scripts/proreser.sh -s [/path/to/input/file.mov] 640x480
```
By default, the `proreser.sh` script will convert your file to ProRes. By adding the `-s` flag we're telling the script to save the output file. By adding `640x480` to the end of the command we're telling the script to resize the file to 640 pixels by 480 pixels.

## Activity 2: Chromakey and Echo

### Chromakey
The Chromakey effect is used to remove any pixel that is a specific color from a video and turn it transparent. Once the color has been turned transparent the video can be overlayed over another video file and the second file will appear "behind" the removed pixels. The bash script chromakey.sh takes care of the chromakey AND the overlay at once. Let's take it step by step.

1. Find any file in the `sample_video_files` directory that has `greenscreen_` in the name. We'll use `greenscreen_skulls` for the main file. You can use any other video file for the second. We'll use `Cat01.mov` for this example
2. We'll see what it looks like to overlay two files without Chromakey
```
ffmpeg -i ./sample_video_files/Cat01.mov -i ./sample_video_files/Skull01.mov -c:v prores -filter_complex '[0:v][1:v]overlay,format=yuv422p10le[v]' -map '[v]' -f matroska - | ffplay -
```
3. Well that wasn't very fun! All you'll see is the original greenscreen video. This is just to prove that you can't overlay files with out the chromakey filter.
4. Now we'll see what it looks like to remove the green in the main file with with the following command
```
ffmpeg -i ./sample_video_files/Skull01.mov -c:v prores -filter_complex 'chromakey=0x00FF00:0.2:0.1' -f matroska - | ffplay -
```
5. You should see that the green has all been removed. The black that's leftover is a special black. It's not actually a black pixel, but an absence of any video data at all! Now see what it looks like when we perform the overlay after chromakeying with the following command:
```
ffmpeg -i ./sample_video_files/Cat01.mov -i ./sample_video_files/Skull01.mov -c:v prores -filter_complex '[1:v]chromakey=0x00FF00:0.2:0.1[1v];[0:v][1v]overlay,format=yuv422p10le[v]' -map '[v]' -f matroska - | ffplay -
```
6. Congrats! You've now chromakeyed a file and overlayed over another file! The script `chromakey.sh` will do this for you automatically, with many extra options. It will also automatically resize the files so that their dimensions match.

### Echo
This echo effect is based off [a classic tape echo effect](https://www.youtube.com/watch?v=y3Whi-g-0A0) for audio. It adds decaying repetitions to an input file. When using this effect make sure to use an effects with big sweeping motions (like dancers!) for the best results. For this example we'll use `retrodancers.mov`

1. Run the default echo effects on RetroDancer.mov with the following command
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov
```
2. For the sake of clarity, this is the same as running this command, which shows all the default arguments used (0.2 second echo, Level 2 trails, Blend mode 1)
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov 0.2 2 1
```
3. Now let's adjust the time of the echo. We can set it to a much shorter time with more trails for a more washy effect:
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov 0.05 5 1
```
4. The fun really starts when we try different blend modes. Let's do the same short delay time with heavy trails, but using the Pheonix blend mode, which is mode 3
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov 0.05 5 3
```
5. We can make it even crazier with the XOR blend mode: 5
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov 0.05 5 7
```
6. XOR mode is wild! But we can actually make it a bit more interesting by really slowing down the delay time and reducing the trails. Let's try that
```
./bash_scripts/echo.sh -p ./sample_video_files/retrodancers.mov 0.5 3 7
```
7. Now you've seen some of what echo can do, try experimenting!

## Activity 3: Bitplane, Blend, Zoom/Scroll

### Bitplane
This one is based on the QCTools bitplane visualization, which “binds” the bit position of the Y, U, and V planes of a video file using FFmpeg’s lutyuv filter. This script has  randomness built right into it, yielding different, often colorful results, each time you run it.

1. Let's start here, with a totally random call:
```
./bash_scripts/bitplane.sh -p ./sample_video_files/jumpinjackflash.mkv
```
2. Let's test this, by playing Jumpin' Jack Flash but visualizing ONLY the 2 bitplane of the Y channel:
```
./bash_scripts/bitplane.sh -p ./sample_video_files/jumpinjackflash.mkv 2 -1 -1
```
You can see how this plays out, with a black and white, fairly blocky image as a result (remember: in this kind of YUV video, the lower bits are "more significant," meaning they contain more image data and serve as the foundational building blocks of your digital image).
Returning to a random run, you should be able to see in your terminal window another fun aspect of this script: it prints out the Y, U, and V values that were either randomly chosen or hand-selected.
```
*******START FFPLAY COMMANDS*******
Y: 5
U: 9
V: 10
```
The idea here is that you can run the script over and over (`q` is a good way to quit FFplay between runs) and when you end up with a video that most suits your artistic temperament, you can easily swap out the `-p` flag for a `-s`.
3. Do this and save your favorite file for our next activity, Zoom/Flip/Scroll.
```
./bash_scripts/bitplane.sh -s ./sample_video_files/jumpinjackflash.mkv FAVORITE_Y FAVORITE_U FAVORITE_V
```

### Zoom/Flip/Scroll
A play on the Line 21 closed caption extraction tool sccyou, zoom/flip/scroller takes a single line of video, zooms in extra close, flips it on its axis, and scrolls up vertically. Designed to visualize and analyze closed captioning information, which lives at the tippy top of the video raster, this re-purposing generates results unlike any other. And, as with bitplane, zoomflipscroller defaults to a randomly selected line (between 1-350) but will also accept a user-specified input.

1. Let's start with the original intention for this code, visualizing the closed captions in Jumpin' Jack Flash. Note: it's confusing, but "line 21" captions typically live around lines 1 or 2 in a digital video (the "21" refers to an analog space):
```
./zoomflipscroller.sh -p ./sample_video_files/jumpinjackflash.mov 1
```
It's fun to be able to see captions in this way, and it helps us understand how this digital information gets "read" and transformed into text, but it's also worth checking out what other lines of video look like this close up.
2. So let's try the script one more time, on the same video, but let's let zoom/flip/scroller randomly choose a line for us:
```
./zoomflipscroller.sh -p ./sample_video_files/jumpinjackflash.mov
```
To us, this results in video that has a distinct modern art vibe; it's all color and lines and weird squiggly shapes.
3. But what might be even MORE FUN is to try it out on our bitplaned Jumpin' Jack Flash:
```
./zoomflipscroller.sh -p ./sample_video_files/jumpinjackflash_bitplane.mov
```

What kinds of results did you get, and did you dig them?

## Activity 4: Pseudocolor, Showcqt