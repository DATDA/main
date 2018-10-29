#   opt_machine.py
#   python 3.5

#   This tool performs the functions of a One-Time-Pad.
#   It takes as input either individually input letters
#       or two files. One file of message-length and one
#       of AT LEAST matching dimensions of letters from the pad.

#   Chris Bugg
#   8/16/17

import os


class OTP:

    def __init__(self):

        while True:

            # Clear Screen
            os.system('clear')

            print(" -> OTP Machine <- ")
            print("lower-case letters only")
            print()
            print("1 - Encrypt")
            print("2 - Decrypt")
            print("3 - Encrypt with file")
            print("4 - Decrypt with file")
            print()
            print("x - Exit")
            print()

            choice = input("Choice: ")

            # Input sanitization
            good_choices = {"1", "2", "3", "4", "x"}

            while choice not in good_choices:
                print("Input Error!")

                choice = input("Try Again: ")

            if choice == "1":

                self.encrypt()

            elif choice == "2":

                self.decrypt()

            elif choice == "3":

                self.encrypt_file()

            elif choice == "4":

                self.decrypt_file()

            else:

                os.system('clear')
                exit()

    def encrypt(self):

        plainText = input("Enter letters (only, no spaces, etc.) to encrypt: ").lower()

        # Convert string to list of chars
        textList = list(plainText)

        padText = input("Enter letters (only, no spaces, etc.) from the pad: ").lower()

        padList = list(padText)

        # Create a new string to hold the ciphertext
        ciphertext = ""

        # For each character in the string
        for x in range(0, (len(textList))):

            # Convert char to int (97 - 122)
            text_int = ord(textList[x])

            # If overflows 122, start from 97
            if int(text_int) > 122:
                text_int -= 26

            # Convert char to int (97 - 122)
            pad_int = ord(padList[x])

            # If overflows 122, start from 97
            if int(pad_int) > 122:
                pad_int -= 26

            cipher_int = text_int + (pad_int - 96)

            if int(cipher_int) > 122:
                cipher_int -= 26

            # Convert back to char
            ciphertext += chr(cipher_int)

        print("Ciphertext: " + ciphertext)
        input("Enter to continue")

    def decrypt(self):

        cipherText = input("Enter letters (only, no spaces, etc.) to decrypt: ").lower()

        # Convert string to list of chars
        cipherList = list(cipherText)

        padText = input("Enter letters (only, no spaces, etc.) from the pad: ").lower()

        padList = list(padText)

        # Create a new string to hold the ciphertext
        plainText = ""

        # For each character in the string
        for x in range(0, (len(cipherText))):

            # Convert char to int (97 - 122)
            cipher_int = ord(cipherText[x])

            # If overflows 122, start from 97
            if int(cipher_int) > 122:
                cipher_int -= 26

            # Convert char to int (97 - 122)
            pad_int = ord(padList[x])

            # If overflows 122, start from 97
            if int(pad_int) > 122:
                pad_int -= 26

            plain_int = cipher_int - (pad_int - 96)

            if int(plain_int) < 97:
                plain_int += 26

            # Convert back to char
            plainText += chr(plain_int)

        print("Plaintext: " + plainText)
        input("Enter to continue")

    def encrypt_file(self):

        plainText_filename = input("Enter just the name of the .txt plaintext file: ")

        plainText_file = open(plainText_filename + ".txt", "r")

        plainText_lines = list(plainText_file)

        plainText_file.close()

        padText_filename = input("Enter just the name of the .txt pad file: ")

        padText_file = open(padText_filename + ".txt", "r")

        padText_lines = list(padText_file)

        padText_file.close()

        cipherText_filename = input("Enter just the name of the FUTURE .txt ciphertext file: ")

        cipherText_file = open(cipherText_filename + ".txt", "w")

        # For each line in the message
        for x in range(0, len(plainText_lines)):

            # Convert string to list of chars
            textList = list(plainText_lines[x].lower())
            padList = list(padText_lines[x].lower())

            # Create a new string to hold the ciphertext
            ciphertext = ""

            # For each character in the string
            for y in range(0, (len(textList)) - 1):

                # Convert char to int (97 - 122)
                text_int = ord(textList[y])

                # If overflows 122, start from 97
                if int(text_int) > 122:
                    text_int -= 26

                # Convert char to int (97 - 122)
                pad_int = ord(padList[y])

                # If overflows 122, start from 97
                if int(pad_int) > 122:
                    pad_int -= 26

                cipher_int = text_int + (pad_int - 96)

                if int(cipher_int) > 122:
                    cipher_int -= 26

                # Convert back to char
                ciphertext += chr(cipher_int)

            ciphertext += "\n"

            cipherText_file.write(ciphertext)

        cipherText_file.close()

    def decrypt_file(self):

        cipherText_filename = input("Enter just the name of the .txt ciphertext file: ")

        cipherText_file = open(cipherText_filename + ".txt", "r")

        cipherText_lines = list(cipherText_file)

        cipherText_file.close()

        padText_filename = input("Enter just the name of the .txt pad file: ")

        padText_file = open(padText_filename + ".txt", "r")

        padText_lines = list(padText_file)

        padText_file.close()

        plainText_filename = input("Enter just the name of the FUTURE .txt plaintext file: ")

        plainText_file = open(plainText_filename + ".txt", "w")

        # For each line in the message
        for x in range(0, len(cipherText_lines)):

            # Convert string to list of chars
            cipherList = list(cipherText_lines[x].lower())
            padList = list(padText_lines[x].lower())

            # Create a new string to hold the plaintext
            plaintext = ""

            # For each character in the string
            for y in range(0, (len(cipherList)) - 1):

                # Convert char to int (97 - 122)
                cipher_int = ord(cipherList[y])

                # If overflows 122, start from 97
                if int(cipher_int) > 122:
                    cipher_int -= 26

                # Convert char to int (97 - 122)
                pad_int = ord(padList[y])

                # If overflows 122, start from 97
                if int(pad_int) > 122:
                    pad_int -= 26

                plain_int = cipher_int - (pad_int - 96)

                if int(plain_int) < 97:
                    plain_int += 26

                # Convert back to char
                plaintext += chr(plain_int)

            plaintext += "\n"

            plainText_file.write(plaintext)

        plainText_file.close()

OTP()
