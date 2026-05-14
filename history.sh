1  git config --global user.name "arisuuuu010"
    2  git config --global user.email "aryumbillopa@uide.edu.ec"
    3  make setup
    4  cd /workspaces/copy-fail-challenge-B-ok
    5  pwd
    6  git config user.name "arisuuuu010"
    7  git config user.email "aryumbillopa@uide.edu.ec"
    8  git config user.name
    9  git config user.email
   10  apt update
   11  apt install -y file patch
   12  grep -R "qemu-system" -n scripts/
   13  code scripts/04_run_qemu.sh
   14  bash -n scripts/04_run_qemu.sh
   15  make setup
   16  ls -lh kernel/build/
   17  cd /workspaces/copy-fail-challenge-B-ok
   18  ROOTFS=/tmp/cf-rootfs
   19  INITRAMFS="$PWD/kernel/build/initramfs.cpio.gz"
   20  rm -rf "$ROOTFS"
   21  mkdir -p "$ROOTFS"
   22  cd "$ROOTFS"
   23  gzip -dc "$INITRAMFS" | cpio -idmv >/dev/null 2>&1
   24  cd /workspaces/copy-fail-challenge-B-ok
   25  cat > /tmp/fix_init.py <<'PY'
   26  from pathlib import Path
   27  p = Path("/tmp/cf-rootfs/init")
   28  s = p.read_text()
   29  lines = []
   30  for line in s.splitlines():
   31      if "exec /bin/su - root" in line: continue
   32      if "exec /bin/su - student" in line: continue
   33      if "exec /usr/bin/su - student" in line: continue
   34      if "exec /bin/busybox su - student" in line: continue
   35      lines.append(line)
   36  block = r"""
   37  mkdir -p /proc /sys /dev /etc
   38  mount -t proc proc /proc 2>/dev/null || true
   39  mount -t sysfs sysfs /sys 2>/dev/null || true
   40  /bin/busybox ifconfig lo 127.0.0.1 up 2>/dev/null || true
   41  /bin/busybox ifconfig eth0 10.0.2.15 netmask 255.255.255.0 up 2>/dev/null || true
   42  /bin/busybox route add default gw 10.0.2.2 2>/dev/null || true
   43  echo "nameserver 10.0.2.3" > /etc/resolv.conf
   44  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
   45  chmod 644 /etc/resolv.conf
   46  exec /bin/busybox su - student
   47  """
   48  s = "\n".join(lines).rstrip() + "\n" + block + "\n"
   49  p.write_text(s)
   50  PY
   51  python3 /tmp/fix_init.py
   52  chmod +x /tmp/cf-rootfs/init
   53  grep -n "student\|resolv\|ifconfig\|mount" /tmp/cf-rootfs/init
   54  ROOTFS=/tmp/cf-rootfs
   55  copy_deps() {   local bin="$1";   ldd "$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//)}
   56  mkdir -p "$ROOTFS/usr/bin"
   57  PYBIN="$(command -v python3)"
   58  install -o root -g root -m 0755 "$PYBIN" "$ROOTFS/usr/bin/python3"
   59  ln -sf python3 "$ROOTFS/usr/bin/python"
   60  copy_deps "$PYBIN"
   61  PYVER="$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")'"
   62  mkdir -p "$ROOTFS/usr/lib"
   63  cp -a "/usr/lib/$PYVER" "$ROOTFS/usr/lib/" 2>/dev/null || true
   64  cp -a /usr/local/lib/python* "$ROOTFS/usr/local/lib/" 2>/dev/null || true
   65  find "$ROOTFS" -type d -exec chmod 755 {} \;
   66  chmod 755 "$ROOTFS/usr/bin/python3"
   67  ROOTFS=/tmp/cf-rootfs
   68  copy_deps() {   local bin="$1";   ldd "$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//)}
   69  SHREAL="$(command -v dash || readlink -f /bin/sh)"
   70  rm -f "$ROOTFS/bin/sh"
   71  install -o root -g root -m 0755 "$SHREAL" "$ROOTFS/bin/sh"
   72  copy_deps "$SHREAL"
   73  mkdir -p "$ROOTFS/usr/bin"
   74  rm -f "$ROOTFS/usr/bin/su"
   75  install -o root -g root -m 4755 /usr/bin/su "$ROOTFS/usr/bin/su"
   76  copy_deps /usr/bin/su
   77  rm -f "$ROOTFS/bin/su"
   78  ln -s /usr/bin/su "$ROOTFS/bin/su"
   79  mkdir -p "$ROOTFS/etc/pam.d" "$ROOTFS/etc/security" "$ROOTFS/lib/x86_64-linux-gnu"
   80  cp -a /etc/pam.d/su "$ROOTFS/etc/pam.d/su" 2>/dev/null || true
   81  cp -a /etc/pam.d/common-* "$ROOTFS/etc/pam.d/" 2>/dev/null || true
   82  cp -a /etc/login.defs "$ROOTFS/etc/login.defs" 2>/dev/null || true
   83  cp -a /etc/security/* "$ROOTFS/etc/security/" 2>/dev/null || true
   84  cp -a /lib/x86_64-linux-gnu/security "$ROOTFS/lib/x86_64-linux-gnu/" 2>/dev/null || true
   85  find "$ROOTFS" -type d -exec chmod 755 {} \;
   86  chmod 755 "$ROOTFS/init"
   87  chmod 755 "$ROOTFS/bin/sh"
   88  chown root:root "$ROOTFS/usr/bin/su"
   89  chmod 4755 "$ROOTFS/usr/bin/su"
   90  find "$ROOTFS" -type f \( -name "*.so" -o -name "*.so.*" -o -name "ld-linux*" \) -exec chmod 755 {};
   91  ls -l "$ROOTFS/bin/sh" "$ROOTFS/bin/su" "$ROOTFS/usr/bin/su"
   92  file "$ROOTFS/bin/sh" "$ROOTFS/usr/bin/su" || true
   93  cd /tmp/cf-rootfs
   94  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
   95  cd /workspaces/copy-fail-challenge-B-ok
   96  ls -lh kernel/build/initramfs.cpio.gz
   97  cd /workspaces/copy-fail-challenge-B-ok
   98  make qemu
   99  ls -l /tmp
  100  echo "Texto del hito 1" > /tmp/hito1.txt
  101  cat /tmp/hito1.txt
  102  cat > /tmp/hito1.txt << 'EOF'
  103  Aquí va el texto del hito 1.
  104  Comandos usados.
  105  Explicación breve.
  106  EOF
  107  cat /tmp/hito1.txt
  108  cd /workspaces/copy-fail-challenge-B-ok
  109  make qemu
  110  cd /workspaces/copy-fail-challenge-B-ok
  111  mkdir -p evidence
  112  code evidence/hito1_vuln_confirmed.txt
  113  cat evidence
  114  cd evidence
  115  ls
  116  cat 
  117  ls -lah
  118  cd ..
  119  cd /workspaces/copy-fail-challenge-B-ok
  120  rm evidence/hito1_vuln_confirmed.txt
  121  cd /workspaces/copy-fail-challenge-B-ok
  122  rm evidence/hito1_vuln_confirmed.txt
  123  ip addr
  124  wget -O- http://example.com | head
  125  cd /workspaces/copy-fail-challenge-B-ok
  126  pwd
  127  /workspaces/copy-fail-challenge-B-ok
  128  make qemu
  129  cd /workspaces/copy-fail-challenge-B-ok
  130  wget https://copy.fail/exp -O /tmp/copy_fail_exp.py
  131  ls -lh /tmp/copy_fail_exp.py
  132  head -3 /tmp/copy_fail_exp.py
  133  ROOTFS=/tmp/cf-rootfs
  134  mkdir -p "$ROOTFS/home/student"
  135  cp /tmp/copy_fail_exp.py "$ROOTFS/home/student/copy_fail_exp.py"
  136  chown 1001:1001 "$ROOTFS/home/student/copy_fail_exp.py" 2>/dev/null || true
  137  chmod 644 "$ROOTFS/home/student/copy_fail_exp.py"
  138  ls -lh "$ROOTFS/home/student/copy_fail_exp.py"
  139  cd /tmp/cf-rootfs
  140  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  141  cd /workspaces/copy-fail-challenge-B-ok
  142  ls -lh kernel/build/initramfs.cpio.gz
  143  cd /tmp/cf-rootfs
  144  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  145  cd /workspaces/copy-fail-challenge-B-ok
  146  ls -lh kernel/build/initramfs.cpio.gz
  147  cd /workspaces/copy-fail-challenge-B-ok
  148  make qemu
  149  cd /workspaces/copy-fail-challenge-B-ok
  150  make qemu
  151  cd /workspaces/copy-fail-challenge-B-ok
  152  pwd
  153  wget https://copy.fail/exp -O /tmp/copy_fail_exp.py
  154  ls -lh /tmp/copy_fail_exp.py
  155  head -3 /tmp/copy_fail_exp.py
  156  cd /workspaces/copy-fail-challenge-B-ok
  157  ROOTFS=/tmp/cf-rootfs
  158  INITRAMFS="$PWD/kernel/build/initramfs.cpio.gz"
  159  rm -rf "$ROOTFS"
  160  mkdir -p "$ROOTFS"
  161  cd "$ROOTFS"
  162  gzip -dc "$INITRAMFS" | cpio -idmv >/dev/null 2>&1
  163  ls -l /tmp/cf-rootfs/init
  164  mkdir -p /tmp/cf-rootfs/home/student
  165  cp /tmp/copy_fail_exp.py /tmp/cf-rootfs/home/student/copy_fail_exp.py
  166  chmod 644 /tmp/cf-rootfs/home/student/copy_fail_exp.py
  167  ls -lh /tmp/cf-rootfs/home/student/copy_fail_exp.py
  168  head -3 /tmp/cf-rootfs/home/student/copy_fail_exp.py
  169  cd /tmp/cf-rootfs
  170  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  171  cd /workspaces/copy-fail-challenge-B-ok
  172  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  173  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep copy_fail_exp.py
  174  cd /workspaces/copy-fail-challenge-B-ok
  175  make qemu
  176  cd /workspaces/copy-fail-challenge-B-ok
  177  ROOTFS=/tmp/cf-rootfs
  178  chmod 755 "$ROOTFS"
  179  chmod 755 "$ROOTFS/home" 2>/dev/null || true
  180  mkdir -p "$ROOTFS/home/student"
  181  chmod 755 "$ROOTFS/home/student"
  182  chown 0:0 "$ROOTFS" "$ROOTFS/home" 2>/dev/null || true
  183  chown 1001:1001 "$ROOTFS/home/student" 2>/dev/null || true
  184  chmod 755 "$ROOTFS/init"
  185  chmod 755 "$ROOTFS/bin" "$ROOTFS/usr" "$ROOTFS/etc" 2>/dev/null || true
  186  chmod 755 "$ROOTFS/bin/sh" 2>/dev/null || true
  187  ls -ld "$ROOTFS" "$ROOTFS/home" "$ROOTFS/home/student"
  188  ls -l "$ROOTFS/init"
  189  wget https://copy.fail/exp -O /tmp/copy_fail_exp.py
  190  cp /tmp/copy_fail_exp.py "$ROOTFS/home/student/copy_fail_exp.py"
  191  chmod 644 "$ROOTFS/home/student/copy_fail_exp.py"
  192  chown 1001:1001 "$ROOTFS/home/student/copy_fail_exp.py" 2>/dev/null || true
  193  ls -lh "$ROOTFS/home/student/copy_fail_exp.py"
  194  cd /tmp/cf-rootfs
  195  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  196  cd /workspaces/copy-fail-challenge-B-ok
  197  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  198  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep -E "init$|home/student|copy_fa"
  199  cd /workspaces/copy-fail-challenge-B-ok
  200  make qemu
  201  cd /workspaces/copy-fail-challenge-B-ok
  202  ROOTFS=/tmp/cf-rootfs
  203  copy_deps() {   local bin="$1";   ldd "$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//)}
  204  mkdir -p "$ROOTFS/usr/bin"
  205  mkdir -p "$ROOTFS/usr/lib"
  206  mkdir -p "$ROOTFS/usr/local/lib"
  207  PYBIN="$(readlink -f "$(command -v python3)")"
  208  install -o root -g root -m 0755 "$PYBIN" "$ROOTFS/usr/bin/python3"
  209  ln -sf python3 "$ROOTFS/usr/bin/python"
  210  copy_deps "$PYBIN"
  211  PYVER="$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")'"
  212  cp -a "/usr/lib/$PYVER" "$ROOTFS/usr/lib/" 2>/dev/null || true
  213  cp -a "/usr/local/lib/$PYVER" "$ROOTFS/usr/local/lib/" 2>/dev/null || true
  214  cp -a /usr/local/lib/python* "$ROOTFS/usr/local/lib/" 2>/dev/null || true
  215  chmod 755 "$ROOTFS/usr/bin/python3"
  216  find "$ROOTFS" -type d -exec chmod 755 {} \;
  217  ls -l "$ROOTFS/usr/bin/python3"
  218  file "$ROOTFS/usr/bin/python3"
  219  ls -lh "$ROOTFS/home/student/copy_fail_exp.py"
  220  cd /tmp/cf-rootfs
  221  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  222  cd /workspaces/copy-fail-challenge-B-ok
  223  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  224  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep -E "usr/bin/python3|home/stude"
  225  cd /workspaces/copy-fail-challenge-B-ok
  226  make qemu
  227  cd /workspaces/copy-fail-challenge-B-ok
  228  ROOTFS=/tmp/cf-rootfs
  229  copy_deps() {   local bin="$1";   ldd "$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//)}
  230  mkdir -p "$ROOTFS/usr/bin"
  231  rm -f "$ROOTFS/usr/bin/su"
  232  install -o root -g root -m 4755 /usr/bin/su "$ROOTFS/usr/bin/su"
  233  copy_deps /usr/bin/su
  234  rm -f "$ROOTFS/bin/su"
  235  ln -s /usr/bin/su "$ROOTFS/bin/su"
  236  mkdir -p "$ROOTFS/etc/pam.d" "$ROOTFS/etc/security" "$ROOTFS/lib/x86_64-linux-gnu"
  237  cp -a /etc/pam.d/su "$ROOTFS/etc/pam.d/su" 2>/dev/null || true
  238  cp -a /etc/pam.d/common-* "$ROOTFS/etc/pam.d/" 2>/dev/null || true
  239  cp -a /etc/login.defs "$ROOTFS/etc/login.defs" 2>/dev/null || true
  240  cp -a /etc/security/* "$ROOTFS/etc/security/" 2>/dev/null || true
  241  cp -a /lib/x86_64-linux-gnu/security "$ROOTFS/lib/x86_64-linux-gnu/" 2>/dev/null || true
  242  chown root:root "$ROOTFS/usr/bin/su"
  243  chmod 4755 "$ROOTFS/usr/bin/su"
  244  find "$ROOTFS" -type d -exec chmod 755 {} \;
  245  find "$ROOTFS" -type f \( -name "*.so" -o -name "*.so.*" -o -name "ld-linux*" \) -exec chmod 755 {};
  246  ls -l "$ROOTFS/bin/su" "$ROOTFS/usr/bin/su"
  247  file "$ROOTFS/usr/bin/su" || true
  248  ls -l /tmp/cf-rootfs/usr/bin/python3
  249  ls -lh /tmp/cf-rootfs/home/student/copy_fail_exp.py
  250  cd /tmp/cf-rootfs
  251  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  252  cd /workspaces/copy-fail-challenge-B-ok
  253  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  254  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep -E "usr/bin/su|bin/su|usr/bin/"
  255  cd /workspaces/copy-fail-challenge-B-ok
  256  make qemu
  257  cd /workspaces/copy-fail-challenge-B-ok
  258  ROOTFS=/tmp/cf-rootfs
  259  cat > "$ROOTFS/init" <<'EOF'
  260  #!/bin/sh
  261  mkdir -p /proc /sys /dev /etc /home/student
  262  mount -t proc proc /proc 2>/dev/null || true
  263  mount -t sysfs sysfs /sys 2>/dev/null || true
  264  mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
  265  /bin/busybox ifconfig lo 127.0.0.1 up 2>/dev/null || true
  266  /bin/busybox ifconfig eth0 10.0.2.15 netmask 255.255.255.0 up 2>/dev/null || true
  267  /bin/busybox route add default gw 10.0.2.2 2>/dev/null || true
  268  echo "nameserver 10.0.2.3" > /etc/resolv.conf
  269  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
  270  chmod 644 /etc/resolv.conf
  271  exec /bin/busybox su - student
  272  EOF
  273  chmod 755 "$ROOTFS/init"
  274  grep -n "su\|busybox\|mount\|ifconfig" "$ROOTFS/init"
  275  ROOTFS=/tmp/cf-rootfs
  276  ls -l "$ROOTFS/usr/bin/su" "$ROOTFS/bin/su"
  277  file "$ROOTFS/usr/bin/su"
  278  ls -l "$ROOTFS/usr/bin/python3"
  279  ls -lh "$ROOTFS/home/student/copy_fail_exp.py"
  280  ROOTFS=/tmp/cf-rootfs
  281  chmod 755 "$ROOTFS"
  282  chmod 755 "$ROOTFS/home"
  283  chmod 755 "$ROOTFS/home/student"
  284  chown 1001:1001 "$ROOTFS/home/student" 2>/dev/null || true
  285  chmod 755 "$ROOTFS/init"
  286  chmod 4755 "$ROOTFS/usr/bin/su"
  287  chmod 644 "$ROOTFS/home/student/copy_fail_exp.py"
  288  chown 1001:1001 "$ROOTFS/home/student/copy_fail_exp.py" 2>/dev/null || true
  289  cd /tmp/cf-rootfs
  290  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  291  cd /workspaces/copy-fail-challenge-B-ok
  292  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  293  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep -E "init$|usr/bin/su|bin/su|us"
  294  cd /workspaces/copy-fail-challenge-B-ok
  295  make qemu
  296  cd /workspaces/copy-fail-challenge-B-ok
  297  ROOTFS=/tmp/cf-rootfs
  298  copy_deps() {   local bin="$1";   ldd "$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//)}
  299  SHREAL="$(command -v dash || readlink -f /bin/sh)"
  300  rm -f "$ROOTFS/bin/sh"
  301  install -o root -g root -m 0755 "$SHREAL" "$ROOTFS/bin/sh"
  302  copy_deps "$SHREAL"
  303  chmod 755 "$ROOTFS/bin/sh"
  304  file "$ROOTFS/bin/sh"
  305  ls -l "$ROOTFS/bin/sh"
  306  rm -f "$ROOTFS/usr/bin/su"
  307  install -o root -g root -m 4755 /usr/bin/su "$ROOTFS/usr/bin/su"
  308  copy_deps /usr/bin/su
  309  rm -f "$ROOTFS/bin/su"
  310  ln -s /usr/bin/su "$ROOTFS/bin/su"
  311  chown root:root "$ROOTFS/usr/bin/su"
  312  chmod 4755 "$ROOTFS/usr/bin/su"
  313  ls -l "$ROOTFS/bin/sh" "$ROOTFS/bin/su" "$ROOTFS/usr/bin/su"
  314  file "$ROOTFS/bin/sh" "$ROOTFS/usr/bin/su"
  315  ls -l "$ROOTFS/usr/bin/python3"
  316  ls -lh "$ROOTFS/home/student/copy_fail_exp.py"
  317  cd /tmp/cf-rootfs
  318  find . -print0 | cpio --null -o --format=newc 2>/dev/null | gzip -9 > /workspaces/copy-fail-challenz
  319  cd /workspaces/copy-fail-challenge-B-ok
  320  gzip -t kernel/build/initramfs.cpio.gz && echo "INITRAMFS OK"
  321  gzip -dc kernel/build/initramfs.cpio.gz | cpio -t 2>/dev/null | grep -E "bin/sh|usr/bin/su|bin/su|u"
  322  cd /workspaces/copy-fail-challenge-B-ok
  323  make qemu
  324  cat /tmp/hito3.txt
  325  make qemu
  326  cd /workspaces/copy-fail-challenge-B-ok
  327  make qemu
  328  cd /workspaces/copy-fail-challenge-B-ok
  329  BZIMAGE="$PWD/kernel/build/bzImage_patched" bash scripts/04_run_qemu.sh
  330  cd /workspaces/copy-fail-challenge-B-ok
  331  ls -lh kernel/build/bzImage_vuln kernel/build/bzImage_patched
  332  sha256sum kernel/build/bzImage_vuln kernel/build/bzImage_patched
  333  cd /workspaces/copy-fail-challenge-B-ok
  334  BZIMAGE="$PWD/kernel/build/bzImage_patched" bash scripts/04_run_qemu.sh
  335  cd /workspaces/copy-fail-challenge-B-ok
  336  qemu-system-x86_64   -nographic   -no-reboot   -kernel "$PWD/kernel/build/bzImage_patched"   -initr0
  337  cd /workspaces/copy-fail-challenge-B-ok/kernel/linux
  338  grep -n "crypto_aead_copy_sgl(null_tfm" -A5 crypto/algif_aead.c
  339  grep -n "af_alg_pull_tsgl(sk, processed" crypto/algif_aead.c
  340  grep -n "af_alg_count_tsgl(sk, processed" crypto/algif_aead.c
  341  python3 - <<'PY'
from pathlib import Path
import re

p = Path("crypto/algif_aead.c")
s = p.read_text()

# Corregir af_alg_pull_tsgl con processed - as
s = re.sub(
    r"af_alg_pull_tsgl\(sk,\s*processed,\s*areq->tsgl,\s*processed\s*-\s*as\);",
    "af_alg_pull_tsgl(sk, processed, areq->tsgl, 0);",
    s
)

# Corregir af_alg_count_tsgl si quedó en varias líneas con processed - as
s = re.sub(
    r"af_alg_count_tsgl\(sk,\s*processed,\s*\n\s*processed\s*-\s*as\)",
    "af_alg_count_tsgl(sk, processed, 0)",
    s
)

# Corregir af_alg_count_tsgl si quedó en una sola línea
s = re.sub(
    r"af_alg_count_tsgl\(sk,\s*processed,\s*processed\s*-\s*as\)",
    "af_alg_count_tsgl(sk, processed, 0)",
    s
)

# Por si quedaron versiones antiguas
s = s.replace(
    "af_alg_count_tsgl(sk, processed);",
    "af_alg_count_tsgl(sk, processed, 0);"
)

s = s.replace(
    "af_alg_pull_tsgl(sk, processed, areq->tsgl);",
    "af_alg_pull_tsgl(sk, processed, areq->tsgl, 0);"
)

s = s.replace(
    "af_alg_pull_tsgl(sk, ctx->used, NULL);",
    "af_alg_pull_tsgl(sk, ctx->used, NULL, 0);"
)

p.write_text(s)

print("[OK] Se corrigieron af_alg_pull_tsgl y af_alg_count_tsgl")
PY

  342  grep -n "af_alg_pull_tsgl(sk, processed" crypto/algif_aead.c
  343  grep -n "af_alg_count_tsgl(sk, processed" -A2 crypto/algif_aead.c
  344  grep -n "crypto_aead_copy_sgl(null_tfm" -A5 crypto/algif_aead.c
  345  git diff -- crypto/algif_aead.c > ../../patches/fix_algif_aead.patch
  346  cd /workspaces/copy-fail-challenge-B-ok
  347  ls -lh patches/fix_algif_aead.patch
  348  head -80 patches/fix_algif_aead.patch
  349  cd /workspaces/copy-fail-challenge-B-ok/kernel/linux
  350  rm -f crypto/algif_aead.o crypto/algif_aead.ko crypto/algif_aead.mod 2>/dev/null || true
  351  make -j$(nproc) bzImage 2>&1 | tee /tmp/hito4_build.log
  352  echo "CODIGO_COMPILACION=${PIPESTATUS[0]}"
  353  cp arch/x86/boot/bzImage ../build/bzImage_patched
  354  cd /workspaces/copy-fail-challenge-B-ok
  355  ls -lh kernel/build/bzImage_patched
  356  sha256sum kernel/build/bzImage_vuln kernel/build/bzImage_patched
  357  cd /workspaces/copy-fail-challenge-B-ok
  358  qemu-system-x86_64   -nographic   -no-reboot   -kernel "$PWD/kernel/build/bzImage_patched"   -initr0
  359  history
root@codespaces-0ae2ed:/workspaces/copy-fail-challenge-B-ok# 