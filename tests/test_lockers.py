"""Portability and installation tests. These do not simulate successful PAM authentication."""
import json,os,pathlib,subprocess,tempfile,unittest,ast,re
ROOT=pathlib.Path(__file__).resolve().parents[1]
class Backends(unittest.TestCase):
 def test_python_syntax(self):
  for p in (ROOT/'themes/shared/lockscreen').glob('*.py'): ast.parse(p.read_text(),filename=str(p))
 def test_all_shell_syntax(self):
  for p in ROOT.glob('themes/**/scripts/*.sh'): subprocess.run(['bash','-n',str(p)],check=True)
  subprocess.run(['bash','-n',str(ROOT/'themes/x11/cosmic-lockscreen/lock.sh')],check=True)
 def environment(self,base):
  env=os.environ.copy(); home=base/'home with spaces'; home.mkdir()
  tools=base/'tools'; tools.mkdir()
  for name in ['hyprlock','gtklock','i3lock','gnome-shell','fc-cache','plasmashell']:
   version={'hyprlock':'hyprlock 0.9.6','gtklock':'gtklock 4.0.0','plasmashell':'plasmashell 6.0.5'}.get(name,'GNOME Shell 51.2')
   p=tools/name; p.write_text('#!/bin/sh\ncase "$1" in --help) echo "--inside-color --clock";; --version) echo "'+version+'";; esac\n');p.chmod(0o755)
  env.update(HOME=str(home),XDG_DATA_HOME=str(home/'data'),XDG_STATE_HOME=str(home/'state'),XDG_CACHE_HOME=str(home/'cache'),PATH=str(tools)+':'+env['PATH'])
  return env,home
 def run_install(self,b,env,*args):
  return subprocess.run(['python3',str(ROOT/'themes/shared/lockscreen/install-backend.py'),'--backend',b,'--source',str(ROOT/'themes'/b/'cosmic-lockscreen'),*args],env=env,text=True,capture_output=True)
 def test_dry_runs_and_experimental_gate(self):
  for b in ['hyprlock','gtklock','x11','gnome']:
   with self.subTest(backend=b), tempfile.TemporaryDirectory() as t:
    env,home=self.environment(pathlib.Path(t)); self.assertEqual(self.run_install(b,env,'--dry-run').returncode,0)
    self.assertFalse((home/'data').exists());self.assertNotEqual(self.run_install(b,env).returncode,0);self.assertFalse((home/'data').exists())
 def test_install_and_restore_each_backend(self):
  for b in ['hyprlock','gtklock','x11','gnome']:
   with self.subTest(backend=b), tempfile.TemporaryDirectory() as t:
    env,home=self.environment(pathlib.Path(t));data=home/'data'
    target=data/'gnome-shell/extensions/cosmic-lockscreen@thu12dta3' if b=='gnome' else data/'cosmic-login'/b
    target.mkdir(parents=True);(target/'old.txt').write_text('previous theme')
    launcher=home/'.local/bin'/('cosmic-'+b+'-lock');launcher.parent.mkdir(parents=True);launcher.write_text('# previous launcher\n')
    native=home/'.config'/b/'config';native.parent.mkdir(parents=True);native.write_text('native configuration stays intact')
    result=self.run_install(b,env,'--allow-experimental');self.assertEqual(result.returncode,0,result.stdout+result.stderr)
    self.assertEqual(native.read_text(),'native configuration stays intact')
    self.assertTrue((target/'cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg').stat().st_size>100000)
    subprocess.run(['bash','-n',str(launcher)],check=True)
    if b=='hyprlock': self.assertNotIn('__ASSET_DIR__',(target/'hyprlock.conf').read_text())
    if b=='gtklock': self.assertNotIn('__BACKGROUND_URI__',(target/'style.css').read_text())
    rollback=subprocess.run(['python3',str(ROOT/'themes/shared/lockscreen/rollback.py'),'--backend',b],env=env,text=True,capture_output=True)
    self.assertEqual(rollback.returncode,0,rollback.stderr);self.assertEqual((target/'old.txt').read_text(),'previous theme')
    self.assertEqual(launcher.read_text(),'# previous launcher\n'); self.assertFalse((target/'JetBrainsMono-Regular.ttf').exists())
 def test_legacy_plasma_discovery_without_writes(self):
  with tempfile.TemporaryDirectory() as t:
   env,home=self.environment(pathlib.Path(t));p=pathlib.Path(t)/'tools/kscreenlocker_greet';p.write_text('#!/bin/sh\necho "--testing --theme"\n');p.chmod(0o755)
   r=subprocess.run(['bash',str(ROOT/'themes/plasma/cosmic-lockscreen/scripts/install.sh'),'--dry-run'],env=env,text=True,capture_output=True)
   self.assertEqual(r.returncode,0,r.stderr);self.assertIn('Backend: lookandfeel',r.stdout);self.assertFalse((home/'data').exists())
 def test_unknown_plasma_api_fails(self):
  with tempfile.TemporaryDirectory() as t:
   env,home=self.environment(pathlib.Path(t));p=pathlib.Path(t)/'tools/kscreenlocker_greet';p.write_text('#!/bin/sh\necho "unknown API"\n');p.chmod(0o755)
   r=subprocess.run(['bash',str(ROOT/'themes/plasma/cosmic-lockscreen/scripts/install.sh'),'--dry-run'],env=env,text=True,capture_output=True)
   self.assertNotEqual(r.returncode,0);self.assertFalse((home/'data').exists())
 def test_x11_refuses_wayland(self):
  env=os.environ.copy();env.update(XDG_SESSION_TYPE='wayland',WAYLAND_DISPLAY='wayland-test',DISPLAY=':999')
  r=subprocess.run(['bash',str(ROOT/'themes/x11/cosmic-lockscreen/lock.sh')],env=env,text=True,capture_output=True)
  self.assertNotEqual(r.returncode,0);self.assertIn('XWayland',r.stderr)
if __name__=='__main__': unittest.main(verbosity=2)
