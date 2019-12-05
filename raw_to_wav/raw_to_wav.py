# -*- coding: utf-8 -*-
"""
@author: roelandd, Flanders Marine Institute
"""

import wave
import os
import time


def convert(raw_file, inp_dir, outp_dir):
    wav_file = raw_file.replace('.raw', '.wav').replace(inp_dir, outp_dir)    # keep name, change directory and extension
    mkdir2(os.path.split(wav_file)[0])    # make directory structure if not existing

    with open(raw_file, 'rb') as raw:
        frames = raw.read()
        
    with wave.open(wav_file, 'wb') as wav:
        wav.setsampwidth(2)         # 16 bit depth = (2 byte)
        wav.setnchannels(1)         # single channel
        wav.setframerate(500000)    # 500 kHz
        wav.writeframesraw(frames)

   
def filelist(inp_dir = ".", outp_dir = None):
    raws =[]    # list of raw-files in input directory and not in its wave-file in output directory
    wavs = []    # list of wave-files in output directory
    if outp_dir:
        for root, dirs, files in os.walk(outp_dir):
            for name in files:
                if name.endswith('.wav'):
                    wavs.append(name)
    for root, dirs, files in os.walk(inp_dir):
        for name in files:
            if name.endswith('.raw'):
                if name.replace('.raw', '.wav') not in wavs:
                    raws.append(os.path.join(root, name))
    return raws


def mkdir2(directory):
    if not os.path.isdir(directory):    # create if not existing
        if not os.path.isdir(os.path.dirname(directory)): mkdir2(os.path.dirname(directory))    # recursive to create nested folders
        os.mkdir(directory)
    return


def convertAll(inp_dir, outp_dir):
    raws = filelist(inp_dir, outp_dir)
    n_files = len(raws)
    if n_files != 0:
        for i, raw in enumerate(raws):
            print(str(i+1)  + ' / ' + str(n_files), sep=' ', end='\r')
            convert(raw, inp_dir, outp_dir)      # convert each file
        print('\nFinished, ' + str(n_files) + ' files converted')
    return n_files

def main():

	print('Programmed by Roeland Develter,')
	print('Flanders Marine Institute 2019')

	input_folder = os.path.abspath(input('raw files directory name: '))

	if not os.path.isdir(input_folder):
		print('The input directory "{}" does not exist'.format(input_folder))
		raise SystemExit
		
	output_folder = os.path.abspath(input('output folder name: '))

	start = time.time()
	n_files = convertAll(input_folder, output_folder)
	end = time.time()

	if n_files == 0:
		print('No unconverted raw files detected.')
	else:
		print('Time elapsed: ' + str(round(end-start, 2)) + \
		  's\tper file: ' +  str(round((end-start)/n_files,4)) + 's')
		  
if __name__ == "__main__":
	main()
