for x in range(1024):
    x = float(x)
    y = -(((x*2*16) / 3579545.0) * 131072.0 - 2048)
    #y = -(((x*2*16) / 3579545.0) * 131072.0)-2048.0
    print "dw ${:04x} ; {}".format(int(round(y)), y)