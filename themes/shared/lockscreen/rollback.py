#!/usr/bin/env python3
import argparse,json,os,pathlib,shutil
p=argparse.ArgumentParser(); p.add_argument('--backend',required=True,choices=['hyprlock','gtklock','x11','gnome']); a=p.parse_args()
home=pathlib.Path.home(); data=pathlib.Path(os.environ.get('XDG_DATA_HOME',home/'.local/share')); state=pathlib.Path(os.environ.get('XDG_STATE_HOME',home/'.local/state'))/'cosmic-login'
backup=pathlib.Path((state/(a.backend+'-backup.txt')).read_text().strip())
assert backup.parent==state/(a.backend+'-backups'),'Unexpected backup location'
m=json.loads((backup/'manifest.json').read_text()); assert m['backend']==a.backend
expected={'theme':data/'gnome-shell/extensions/cosmic-lockscreen@thu12dta3' if a.backend=='gnome' else data/'cosmic-login'/a.backend,'launcher':home/'.local/bin'/('cosmic-'+a.backend+'-lock'),'fonts':data/'fonts'/('cosmic-login-'+a.backend)}
for r in m['records']:
 target=expected[r['name']]; assert str(target)==r['path']
 if target.is_dir(): shutil.rmtree(target)
 elif target.exists(): target.unlink()
 if r['existed']:
  target.parent.mkdir(parents=True,exist_ok=True)
  if (backup/r['name']).is_dir(): shutil.copytree(backup/r['name'],target)
  else: shutil.copy2(backup/r['name'],target)
print('Previous theme files restored. Restore any manual key bindings separately using your saved configuration.')
