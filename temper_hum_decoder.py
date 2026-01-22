#!/usr/bin/env python3
"""
TEMPerHUM_V4.1 decoder for device 3553:a001
Decodes temperature and humidity from hex_data
"""

import json
import subprocess
import sys

def decode_temperhum_v41(hex_data):
    """
    Decode TEMPerHUM_V4.1 hex data format
    Format: 802009740e9e0000
    Bytes 2-3: Temperature (big-endian, divide by 100)
    Bytes 4-5: Humidity (big-endian, divide by 100)
    """
    try:
        # Remove '0x' prefix if present and convert to bytes
        if hex_data.startswith('0x'):
            hex_data = hex_data[2:]
        
        data_bytes = bytes.fromhex(hex_data)
        
        # Extract temperature (bytes 2-3, big-endian)
        temp_raw = (data_bytes[2] << 8) | data_bytes[3]
        temperature = temp_raw / 100.0
        
        # Extract humidity (bytes 4-5, big-endian)
        hum_raw = (data_bytes[4] << 8) | data_bytes[5]
        humidity = hum_raw / 100.0
        
        return temperature, humidity
    except Exception as e:
        return None, None

def main():
    # Run temper-read and capture JSON output
    try:
        result = subprocess.run(
            ['/usr/local/bin/temper-read', '--json'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=5
        )
        
        # Only try to parse if we have stdout
        if not result.stdout.strip():
            print("Error: No output from temper-read", file=sys.stderr)
            sys.exit(1)
        
        devices = json.loads(result.stdout)
        
        # Find TEMPerHUM_V4.1 devices
        for device in devices:
            firmware = device.get('firmware', '').strip('\x00')
            
            # Handle TEMPerHUM_V4.1 with custom decoder
            if firmware == 'TEMPerHUM_V4.1':
                hex_data = device.get('hex_data', '')
                
                if hex_data:
                    temp, hum = decode_temperhum_v41(hex_data)
                    
                    if temp is not None and hum is not None:
                        print(f"Bus {device['busnum']:03d} Dev {device['devnum']:03d} "
                              f"{device['vendorid']:04x}:{device['productid']:04x} "
                              f"{firmware} Temperature: {temp:.2f}°C Humidity: {hum:.2f}%")
            
            # Handle other devices with built-in support
            elif 'internal temperature' in device:
                temp = device['internal temperature']
                firmware = device.get('firmware', 'Unknown')
                
                output = (f"Bus {device['busnum']:03d} Dev {device['devnum']:03d} "
                         f"{device['vendorid']:04x}:{device['productid']:04x} "
                         f"{firmware} Temperature: {temp:.2f}°C")
                
                if 'internal humidity' in device:
                    hum = device['internal humidity']
                    output += f" Humidity: {hum:.2f}%"
                
                print(output)
    
    except subprocess.TimeoutExpired:
        print("Error: temper-read timed out", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Could not parse JSON output", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
