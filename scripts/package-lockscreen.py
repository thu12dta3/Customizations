#!/usr/bin/env python3
"""Build deterministic standalone ZIPs; resolve shared symlinks into regular files."""
from pathlib import Path
import hashlib,stat,zipfile
root=Path(__file__).resolve().parents[1]
outdir=root/'downloads';outdir.mkdir(exist_ok=True)

def files(base):
 return [p for p in sorted(base.rglob('*')) if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc']
def write_archive(name,entries):
 out=outdir/name
 with zipfile.ZipFile(out,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
  for p,relative in entries:
   info=zipfile.ZipInfo(relative.as_posix(),(2026,1,1,0,0,0));info.create_system=3
   info.external_attr=(stat.S_IFREG|(0o755 if p.suffix=='.sh' else 0o644))<<16
   info.compress_type=zipfile.ZIP_DEFLATED;archive.writestr(info,p.read_bytes())
 digest=hashlib.sha256(out.read_bytes()).hexdigest();out.with_suffix('.zip.sha256').write_text(f'{digest}  {out.name}\n')
 print(f'{out.relative_to(root)} ({out.stat().st_size:,} bytes)')
packages={'plasma':('cosmic-lockscreen.zip','cosmic-lockscreen')}
packages.update({b:(f'cosmic-lockscreen-{b}-experimental.zip',f'cosmic-{b}-lockscreen') for b in ['hyprlock','gtklock','gnome','x11']})
for backend,(archive,folder) in packages.items():
 source=root/'themes'/backend/'cosmic-lockscreen';prefix=Path(folder)
 entries=[(p,prefix/p.relative_to(source)) for p in files(source)];entries.append((root/'LICENSE',prefix/'LICENSE'));write_archive(archive,entries)
prefix=Path('cosmic-lockscreens')
entries=[]
for backend in packages:
 source=root/'themes'/backend/'cosmic-lockscreen'
 entries.extend((p,prefix/p.relative_to(root)) for p in files(source))
for source in [root/'themes/shared/lockscreen',root/'docs',root/'tests']:
 entries.extend((p,prefix/p.relative_to(root)) for p in files(source))
for name in ['install.sh','LICENSE']:entries.append((root/name,prefix/name))
entries.extend([
 (root/'docs/ALL_BUNDLE_README.md',prefix/'README.md'),
 (root/'docs/ALL_BUNDLE_README.pt-BR.md',prefix/'README.pt-BR.md'),
])
write_archive('cosmic-lockscreens-all.zip',entries)
