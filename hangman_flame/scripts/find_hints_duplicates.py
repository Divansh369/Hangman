import re
from collections import Counter

path = 'lib/data/hints.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

keys = re.findall(r"'([^']+)'\s*:", text)
counts = Counter(keys)
duplicates = [(k, v) for k, v in counts.items() if v > 1]
if not duplicates:
    print('No duplicate keys')
else:
    for k, v in duplicates:
        print(f"{k}: {v}")
    
# print total keys for reference
print('\nTotal keys:', len(keys))
