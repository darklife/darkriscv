#!/usr/bin/env python3

import serial
import time
import glob
import sys

def communicate_with_device(device_path, messages, timeout=0.05, baudrate=115200):
    """
    Open a serial connection to a device, send messages,
    and read the response.

    Args:
        device_path (str): device path to open
        messages (list[str]): ASCII messages to send
        timeout (float): Read timeout in seconds
        baudrate (int): Baud rate for serial communication
    """
    try:
        ser = serial.Serial(
            port=device_path,
            baudrate=baudrate,
            timeout=timeout,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE
        )
        # Add a small delay to ensure port is fully open
#        time.sleep(0.2)
        for message in messages:
            message += "\n"
            # Convert string to bytes and write to device
            ser.write(message.encode('ascii'))
            # Skip first response (command echo)
            response = ser.readline().decode('ascii').strip()
            if response != message.strip():
                print(f"Error: first {response=} != {message=}")
                break
            while 1:
                response = ser.readline().decode('ascii').strip()
                if not response:
                    break
                elif response.endswith(">"):
                    break
                elif message.startswith("bb "):
                    for resp in response.splitlines():
                        #print(f"{response=}")
                        if ':' not in resp:
                            val = int(resp, 16) & 0xffff
                            print(f"{val=:x}");
                else:
                    for resp in response.splitlines():
                        print(f"{response}")
        ser.close()
    except serial.SerialException as e:
        print(f"Error communicating with {device_path}: {e}")
if __name__ == "__main__":
    device_path = glob.glob('/dev/ttyUSB?')[0]
    args = sys.argv
    #print(f"{args}")
    if len(args) > 1:
        messages = args[1:]
        #print(f"{messages=}")
    else:
        messages = [
        "set_bb 1",
        #"bb 7 f b 9 b 8 a 8 a 8 a 9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b f 7",# WHOAMI 1fff => ff33
        "bb 7 f b 9 b 9 b 9 b 8 a 9 b 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a f 7",# READ OUT_X => ffa007
        ]
    communicate_with_device(device_path, messages)
