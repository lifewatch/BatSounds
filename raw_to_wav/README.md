# raw_to_wav.py

Written in Python 3.7

Converts all .raw-files in the input folder (and subfolders!) to .wav-files with given parameters. Skips raw-files that already have a wav-file present in the output folder.

Parameters are adjusted for Batcorders, i.e. 500kHz sample rate, 16 bit depth, 1 channel.

Can be compiled to an executable without modification.
