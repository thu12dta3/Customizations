#!/usr/bin/env python3
"""Build a standalone ZIP, dereferencing the source package's shared assets."""
from pathlib import Path
import hashlib
import stat
import zipfile

root = Path(__file__).resolve().parents[1]
source = root / 'themes/plasma/cosmic-lockscreen'
out = root / 'downloads/cosmic-lockscreen.zip'
out.parent.mkdir(exist_ok=True)
entries = [(p, p.relative_to(source)) for p in sorted(source.rglob('*')) if p.is_file()]
entries.append((root / 'LICENSE', Path('LICENSE')))
with zipfile.ZipFile(out, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
    for path, relative in entries:
        info = zipfile.ZipInfo('cosmic-lockscreen/' + relative.as_posix(), (2026, 1, 1, 0, 0, 0))
        info.create_system = 3
        mode = 0o755 if relative.suffix == '.sh' else 0o644
        info.external_attr = (stat.S_IFREG | mode) << 16
        info.compress_type = zipfile.ZIP_DEFLATED
        archive.writestr(info, path.read_bytes())
digest = hashlib.sha256(out.read_bytes()).hexdigest()
out.with_suffix('.zip.sha256').write_text(f'{digest}  {out.name}\n')
print(f'{out.relative_to(root)} ({out.stat().st_size:,} bytes)')
