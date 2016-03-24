print "FreqLUT:"

for x in range(1024):
    x = float(x)
    #y = 2048 - (((x*2*16) / 3579545.0) * 131072.0 )
    #y = -(((x*2*16) / 3579545.0) * 131072.0)-2048.0
    if x == 0:
        y = 2047
    else:
        y = 2048 - (131072.0 / (3579545.0 / (x*32)))
    print "dw ${:04x} ; {}".format(int(round(y)), y)

print "FreqLUTCh3:"

for x in range(1024):
    x = float(x)
    #y = 2048 - (((x*2*16) / 3579545.0) * 131072.0 )
    #y = -(((x*2*16) / 3579545.0) * 131072.0)-2048.0
    if x == 0:
        y = 2047
    else:
        y = 2048 - ((131072.0*2) / (3579545.0 / (x*32)))
    if y < 0:
        y = 0
    print "dw ${:04x} ; {}".format(int(round(y)), y)
