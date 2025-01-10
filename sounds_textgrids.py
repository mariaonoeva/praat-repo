# Hi, I'm Masha Onoeva.
# This is the script that is supposed to create Praat TextGrids from txt files and audios.

# The script requires two files in the same folder -- txt file with audio text and wav file with sound.
# It is supposed to work for languages that use spaces as word separators.

# I use praatio library to create TextGrids for wav files.
# Source: https://github.com/timmahrt/praatIO/blob/main/tutorials/tutorial1_intro_to_praatio.ipynb
# This library cannot work with STEREO sound, so I need to convert them all sound to MONO first.
# This is why I need pydub library.

# Text from txts is normalized (removing punctuation and capitalization), then added to TextGrids.

# As the output there should be:
# - a folder with mono sounds
# - TextGrids aligned with both mono and stereo files either in the same or a separate folder

# OG is 'original' (hehe)
# Some ChatGPT assistance was required :D (mostly with Stereo to Mono conversion)

import os  # directory navigation
from os.path import join  # directory navigation

from praatio import textgrid, audio  # for praat
from praatio.utilities.constants import Interval
from pydub import AudioSegment  # for stereo-mono convertion

import re

# Paths: here I create variable for paths that I need.
inputPath = join('..', 'data', 'test')  # this is the path with OG audios
monoAudioPath = join(inputPath, "mono_audios")  # this is the path that will be created for mono audios
textgridOutputPath = inputPath  # this lines puts all TextGrids in the same folder
# textgridOutputPath = join(inputPath, 'textgrids')  # this generates a separate subfolder

# Ensure output directories exist
if not os.path.exists(monoAudioPath):
    os.mkdir(monoAudioPath)  # if they don't, this will create them

if not os.path.exists(textgridOutputPath):
    os.mkdir(textgridOutputPath)

# Step 1: Convert all audio files to mono and save them in the mono folder
print("Converting audio files to mono...")  # a cool initiation line in the terminal
for fname in os.listdir(inputPath):  # loops through OG folder
    name, ext = os.path.splitext(fname)
    if ext != ".wav":
        continue

    input_audio_path = join(inputPath, fname)
    mono_audio_path = join(monoAudioPath, f"{name}.wav")

    # Convert to mono if needed
    audio_file = AudioSegment.from_file(input_audio_path)
    if audio_file.channels > 1:
        print(f"Converting {fname} to mono...")
        mono_audio = audio_file.set_channels(1)
        mono_audio.export(mono_audio_path, format="wav")
        print(f"Saved mono audio as {mono_audio_path}")
    else:
        print(f"{fname} is already mono. Copying to mono folder...")
        if not os.path.exists(mono_audio_path):
            audio_file.export(mono_audio_path, format="wav")  # Save mono version
print("Mono audio processing complete.\n")

# Step 2: Create TextGrids for mono audio files
print("Generating TextGrids...")
for fname in os.listdir(monoAudioPath):  # loops through the mono folder
    name, ext = os.path.splitext(fname)
    if ext != ".wav":
        continue

    mono_audio_path = join(monoAudioPath, fname)
    textgrid_path = join(textgridOutputPath, f"{name}.TextGrid")
    txt_file_path = join(inputPath, f"{name}.txt")

    # measures duration of a mono sound
    duration = audio.getDuration(mono_audio_path)

    # opens a txt file with the same name as the sound
    with open(txt_file_path) as f:
        contents = f.read()

    # preparations for a txt file
    split_content = re.sub(r'[^\w\s]', '', contents)  # removes punctuation
    clean_split_content = split_content.split(' ')  # splits by space
    split_content_words = [w.lower() for w in clean_split_content]  # makes all words lower case
    count_content = len(split_content_words)  # measures how much words are there
    len_word = duration / count_content  # calculates duration for a word

    # Here I generate intervals for each word:
    # IntervalTiers and PointTiers take 4 arguments:
    # - tier name
    # - a list of intervals or points (here I need to put my txts)
    # - start time
    # - end time
    item_intervals = []  # creating an empty list where all intervals will be stored
    start_time = 0.0  # start time for the first word

    # This was a bit confusing but I guess it is better this way
    for word in split_content_words:
        end_time = start_time + len_word
        item_intervals.append(Interval(start_time, end_time, word))
        start_time = end_time  # Update start_time for the next word

    # Create an empty TextGrid with a "words" tier spanning the entire duration
    wordTier = textgrid.IntervalTier('words', item_intervals, 0, duration)
    tg = textgrid.Textgrid()
    tg.addTier(wordTier)

    # Save the TextGrid file
    tg.save(textgrid_path, format="short_textgrid", includeBlankSpaces=True)
    print(f"Generated TextGrid: {textgrid_path}")
print("TextGrid generation complete.")
