# Docker Desktop(WSL2 커널)에서는 pyperclip 이 /proc/version 의 microsoft 를 보고 clip.exe 를 찾는다. 이 컨테이너는 X11(:99) 이라 xclip 으로 고정
try:
    import pyperclip

    pyperclip.set_clipboard('xclip')
except Exception:
    pass