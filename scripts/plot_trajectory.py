#!/usr/bin/env python3
import csv
import sys
import matplotlib.pyplot as plt

path = sys.argv[1] if len(sys.argv) > 1 else 'trajectory.csv'

g_x, g_y = [], []
l_x, l_y = [], []
o_x, o_y = [], []

with open(path, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        t = row['type']
        x = float(row['x'])
        y = float(row['y'])
        if t == 'G':
            g_x.append(x); g_y.append(y)
        elif t == 'L':
            l_x.append(x); l_y.append(y)
        elif t == 'O':
            o_x.append(x); o_y.append(y)

plt.figure(figsize=(8,8))
if g_x:
    plt.plot(g_x, g_y, '-b', label='Global')
if l_x:
    plt.plot(l_x, l_y, '-r', label='Local (optimized)')
if o_x:
    plt.scatter(o_x, o_y, marker='x', c='k', label='Obstacles')

plt.legend()
plt.axis('equal')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Trajectory')
plt.grid(True)

out_png = path.replace('.csv', '.png')
plt.savefig(out_png)
print('Saved plot to', out_png)
plt.show()
