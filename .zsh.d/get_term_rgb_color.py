import os, sys, termios
import select, fcntl
import ctypes

if (len(sys.argv) < 2):
    exit(1)

lflag = 3
sz = ctypes.c_int()

fd = os.open(os.readlink("/proc/self/fd/0"), os.O_RDWR | os.O_NOCTTY)
p = select.poll()
p.register(fd, select.POLLIN)

t = termios.tcgetattr(fd)
old_t = t[:]
t[lflag] &= ~(termios.ICANON | termios.ECHO)
termios.tcsetattr(fd, termios.TCSAFLUSH, t)

rgb = []

for x in sys.argv[1:]:
    if x == 'bg':
        os.write(fd, bytes("\033]11;?\033\\", "UTF-8"))
    elif x == 'fg':
        os.write(fd, bytes("\033]10;?\033\\", "UTF-8"))
    elif x.isdigit() and int(x) >= 0 and int(x) <= 255:
        os.write(fd, bytes("\033]4;%d;?\033\\" % int(x), "UTF-8"))
    else:
        termios.tcsetattr(fd, termios.TCSAFLUSH, old_t)
        os.close(fd)
        exit(1)

    if (not p.poll(1000)):
        termios.tcsetattr(fd, termios.TCSAFLUSH, old_t)
        os.close(fd)
        exit(1)

    fcntl.ioctl(fd, termios.FIONREAD, sz)
    r = os.read(fd, sz.value).decode("UTF-8")

    try:
        i = r.index("rgb")
    except ValueError:
        termios.tcsetattr(fd, termios.TCSAFLUSH, old_t)
        os.close(fd)
        exit(1)

    # rgba not supported
    if (r[i+3] == 'a'):
        termios.tcsetattr(fd, termios.TCSAFLUSH, old_t)
        os.close(fd)
        exit(1)

    rgb.append(r[i:i+18])

termios.tcsetattr(fd, termios.TCSAFLUSH, old_t)
os.close(fd)

r = ''
for x in rgb:
    r += x + ' '
sys.stdout.write(r[:-1])
sys.stdout.flush()
exit(0)
