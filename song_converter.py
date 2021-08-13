#!/bin/python3

# https://github.com/robsoncouto/arduino-songs

# Converts an Arduino Song ino file into a binary file for the Music program
# Pipe in the file using something like cat or curl

import sys
import re

NOTES = {
    'NOTE_B0': 31,
    'NOTE_C1': 33,
    'NOTE_CS1': 35,
    'NOTE_D1': 37,
    'NOTE_DS1': 39,
    'NOTE_E1': 41,
    'NOTE_F1': 44,
    'NOTE_FS1': 46,
    'NOTE_G1': 49,
    'NOTE_GS1': 52,
    'NOTE_A1': 55,
    'NOTE_AS1': 58,
    'NOTE_B1': 62,
    'NOTE_C2': 65,
    'NOTE_CS2': 69,
    'NOTE_D2': 73,
    'NOTE_DS2': 78,
    'NOTE_E2': 82,
    'NOTE_F2': 87,
    'NOTE_FS2': 93,
    'NOTE_G2': 98,
    'NOTE_GS2': 104,
    'NOTE_A2': 110,
    'NOTE_AS2': 117,
    'NOTE_B2': 123,
    'NOTE_C3': 131,
    'NOTE_CS3': 139,
    'NOTE_D3': 147,
    'NOTE_DS3': 156,
    'NOTE_E3': 165,
    'NOTE_F3': 175,
    'NOTE_FS3': 185,
    'NOTE_G3': 196,
    'NOTE_GS3': 208,
    'NOTE_A3': 220,
    'NOTE_AS3': 233,
    'NOTE_B3': 247,
    'NOTE_C4': 262,
    'NOTE_CS4': 277,
    'NOTE_D4': 294,
    'NOTE_DS4': 311,
    'NOTE_E4': 330,
    'NOTE_F4': 349,
    'NOTE_FS4': 370,
    'NOTE_G4': 392,
    'NOTE_GS4': 415,
    'NOTE_A4': 440,
    'NOTE_AS4': 466,
    'NOTE_B4': 494,
    'NOTE_C5': 523,
    'NOTE_CS5': 554,
    'NOTE_D5': 587,
    'NOTE_DS5': 622,
    'NOTE_E5': 659,
    'NOTE_F5': 698,
    'NOTE_FS5': 740,
    'NOTE_G5': 784,
    'NOTE_GS5': 831,
    'NOTE_A5': 880,
    'NOTE_AS5': 932,
    'NOTE_B5': 988,
    'NOTE_C6': 1047,
    'NOTE_CS6': 1109,
    'NOTE_D6': 1175,
    'NOTE_DS6': 1245,
    'NOTE_E6': 1319,
    'NOTE_F6': 1397,
    'NOTE_FS6': 1480,
    'NOTE_G6': 1568,
    'NOTE_GS6': 1661,
    'NOTE_A6': 1760,
    'NOTE_AS6': 1865,
    'NOTE_B6': 1976,
    'NOTE_C7': 2093,
    'NOTE_CS7': 2217,
    'NOTE_D7': 2349,
    'NOTE_DS7': 2489,
    'NOTE_E7': 2637,
    'NOTE_F7': 2794,
    'NOTE_FS7': 2960,
    'NOTE_G7': 3136,
    'NOTE_GS7': 3322,
    'NOTE_A7': 3520,
    'NOTE_AS7': 3729,
    'NOTE_B7': 3951,
    'NOTE_C8': 4186,
    'NOTE_CS8': 4435,
    'NOTE_D8': 4699,
    'NOTE_DS8': 4978,
    'REST': 0
}


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print('Usage: python3 song_converter.py <song_out>.bin <optional_tempo>')
        exit(-1)

    tempo = None

    notes = []
    for line in sys.stdin.readlines():
        cleaned = line.replace(' ', '')
        tempo_match = re.search(r'tempo=(\d+)', cleaned)
        if tempo_match:
            tempo = int(tempo_match[1])
        for match in re.findall(r'(NOTE_[A-G]S?\d|REST),(-?\d+)', cleaned):
            notes.append({
                'note': match[0],
                'length': match[1]
            })

    if len(sys.argv) == 3:
        tempo = int(sys.argv[2])

    if tempo is None:
        print('Warning: Could not determine song tempo')
        tempo = 120

    whole_note = int(24000 / tempo)  # Whole note length in centiseconds

    data = bytearray(len(notes) * 3 + 1)
    data[-1] = 0xFF  # Stop byte
    for i in range(len(notes)):
        frequency = NOTES[notes[i]['note']]
        period = 1 / frequency / 2 if frequency > 0 else 0
        length = int(notes[i]['length'])
        millis = int(period * 1000)
        centimillis = (int(period * 100000)) % 100
        duration = int(whole_note * (1 / abs(length)) * (3 / 2 if length < 0 else 1))
        if duration > 0xFE:
            print('Warning: Maximum note length exceeded')
        data[i * 3] = min(0xFE, duration)
        data[i * 3 + 1] = millis
        data[i * 3 + 2] = centimillis
        # print(f'Note: {notes[i]["note"]}({length}) --- Length: {data[i * 3]}, Millis: {millis}, Centimillis: {centimillis}')

    f = open(sys.argv[1], "wb")
    f.write(data)
    f.close()


if __name__ == '__main__':
    main()
