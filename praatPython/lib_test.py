import parselmouth

# Load a Praat script and run it
praat_script = "/Users/maria.onoeva/Desktop/new_folder/GitHub/praat-repo/MO_drawing_script.praat"
sound = parselmouth.Sound("/Users/maria.onoeva/Desktop/AwesomeVault/FDSL17-with-Masha/sounds_us/cut_decl_2.wav")
# textgrid = parselmouth.TextGrid("/Users/maria.onoeva/Desktop/AwesomeVault/FDSL17-with-Masha/sounds_us/cut_decl_2.TextGrid")

# Run the script with arguments
# I need to redo my initial praat script so this works as needed
result = parselmouth.praat.run_file(praat_script, sound, 0.0, 1.0)

# Print the result
print(result)
