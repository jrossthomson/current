import json, re, sys, os
def find_sequence(obj):
    if isinstance(obj, str):
        if re.match(r'^[ACDEFGHIKLMNPQRSTVWY]{15,}$', obj): return obj
    elif isinstance(obj, list):
        for item in obj:
            if res := find_sequence(item): return res
    elif isinstance(obj, dict):
        for v in obj.values():
            if res := find_sequence(v): return res
    return None

try:
    input_path = '/inputs/colab_input.json'
    if not os.path.exists(input_path): sys.exit(1)
    raw = json.load(open(input_path))
    seq = find_sequence(raw)
    if seq:
        final = {'queries': {'reconstructed': {'chains': [{'molecule_type': 'protein', 'chain_ids': ['A'], 'sequence': seq}]}}}
        json.dump(final, open('/tmp/fixed_input.json', 'w'), indent=2)
    else:
        sys.exit(1)
except:
    sys.exit(1)
