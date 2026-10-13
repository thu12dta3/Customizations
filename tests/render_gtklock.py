#!/usr/bin/env python3
"""Render GTK3 theme widgets in an offscreen window; never start gtklock or PAM."""
import pathlib,sys
import gi
gi.require_version('Gtk','3.0')
from gi.repository import Gtk,Gdk
root=pathlib.Path(__file__).resolve().parents[1]/'themes/gtklock/cosmic-lockscreen'
provider=Gtk.CssProvider()
css=(root/'style.css').read_text().replace('__BACKGROUND_URI__',(root/'cosmic-timetraveler-LhDWW8PhPoE-unsplash.jpg').resolve().as_uri())
provider.load_from_data(css.encode())
builder=Gtk.Builder();builder.add_from_file(str(root/'layout.ui'))
for name in ['window-box','info-box','time-box','clock-label','date-label','body-revealer','body-grid','input-label','input-field','message-revealer','message-scrolled-window','message-box','warning-label','error-label','unlock-button']:
 assert builder.get_object(name) is not None,name
win=Gtk.OffscreenWindow();win.set_default_size(1280,720);win.add(builder.get_object('window-box'))
Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(),provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
builder.get_object('clock-label').set_text('21:34');builder.get_object('date-label').set_text('Segunda-feira, 12 de outubro')
builder.get_object('body-revealer').set_reveal_child(True)
win.show_all()
while Gtk.events_pending(): Gtk.main_iteration()
pixbuf=win.get_pixbuf();assert pixbuf is not None
if len(sys.argv)>1: pixbuf.savev(sys.argv[1],'png',[],[])
win.destroy()
print('GTK3 native widget IDs, CSS and visual rendering passed. This is not a PAM/lock test.')
