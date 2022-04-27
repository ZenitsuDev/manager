public class ImageAttribView : Gtk.Box {
    public ImageInfoView info_page { get; construct; }
    public ImageAttribView (ImageInfoView info_page) {
        Object (
            info_page: info_page,
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0
        );
    }

    construct {
        FileInfo? info = null;
        try {
            info = info_page.basis.file.query_info ("standard::*", 0);
        } catch (Error e) {
            print ("%s\n", e.message);
        }

        var title = new Gtk.Label (info.get_name ()) {
            wrap = true,
            wrap_mode = Pango.WrapMode.CHAR,
            halign = Gtk.Align.START
        };
        title.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        // var file_size = info.get_attribute_as_string ("standard::size");
        var path = new Gtk.Label ("Path: %s\n".printf (info_page.basis.file.get_path ())) {
            halign = Gtk.Align.START,
            wrap = true,
            wrap_mode = Pango.WrapMode.CHAR,
            margin_top = 20
        };

        append (title);
        append (path);

        margin_start = 20;
        margin_top = 20;
    }
}
