import parselmouth

# Load a Praat script and run it
praat_script = "/Users/maria.onoeva/Desktop/new_folder/GitHub/praat-repo/tutorial.praat"
# Run the script with arguments
# I need to redo my initial praat script so this works as needed
result = parselmouth.praat.run_file(praat_script)

# Print the result
print(result)
