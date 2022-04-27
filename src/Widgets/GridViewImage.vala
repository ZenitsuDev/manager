public class GridViewImage : Gtk.Widget {
    public Gtk.Image image { get; set; }
    public File file { get; construct; }
    public Gdk.Texture? texture = null;

    public GridViewImage (File file) {
        Object (file: file);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~GridViewImage () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        try {
            texture = Gdk.Texture.from_file (file); // I used texture for some reason
        } catch (Error e) {
            printerr ("%s\n", e.message);
        }
        image = new Gtk.Image.from_paintable (texture) {
            width_request = 150,
            height_request = 150,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            can_focus = false
        };
        image.add_css_class (Granite.STYLE_CLASS_CARD); // I make them look like cards because it's cute.
        image.set_parent (this);
    }
}
