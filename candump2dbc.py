#!/usr/bin/env python3

import sys

if len(sys.argv)==1:
    print("Nein!")
    sys.exit(0)

import json

class CanMsg(object):
    def __init__(self, canid, data):
        self.canid=canid
        self.data=data
        
    def __repr__(self):
        return f"CAN<{self.canid}, {self.data}>"
def parse_log(log_file):
    messages = list()
    with open(log_file, "r") as f:
        for can_msg in f.readlines():
            can_id, can_data = can_msg.strip().split(" ")[-1].split("#")
            cm = CanMsg(can_id, can_data)
            messages.append(cm)
    #
    unique_datas = dict()
    #
    for canid in set([msg.canid for msg in messages]):
        id_datas = set([msg.data for msg in messages if msg.canid==canid])
        unique_datas[canid] = id_datas
    #
    return unique_datas

data = parse_log(sys.argv[1])

def gen_dbc_entry(can_id):
    dbc_entry = {'id': int(f"{can_id}", 16),
     'is_extended_frame': False,
     'name': f'Ox{can_id}',
     'signals': list()}

    def gen_sig(start_bit, bit_length=8):
        return {'bit_length': bit_length,
         'factor': "1",
         'is_big_endian': True,
         'is_float': False,
         'is_signed': False,
         'name': f'Ox{can_id}_{start_bit}',
         'offset': "0",
         'start_bit': start_bit
        }
    
    for start_bit in range(0, 64, 8):
        sig = gen_sig(start_bit=start_bit)
        dbc_entry["signals"].append(sig)
        
    return dbc_entry

dbc = {
    "messages": list()
}

unique_message_dbc_threshold = 5

for can_id, can_messages in data.items():
    if len(can_messages)< unique_message_dbc_threshold:
        continue
    dbc["messages"].append(gen_dbc_entry(can_id))


dbc_json = "tesla_dbc.json"
print("Machen dbc-json")
with open(dbc_json, "w") as fp:
    json.dump(obj=dbc, fp=fp, indent=4, sort_keys=True)
    
import subprocess

subprocess.check_output(f"canconvert {dbc_json} tesla_autogen.dbc".split())
