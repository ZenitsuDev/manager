public class HeaderBar : Gtk.Widget {
    public Gtk.HeaderBar header { get; set; }
    public Gtk.Stack title_widget { get; set; }
    public Gtk.Button return_button { get; set; }
    public Gtk.Button hide_flap { get; set; }
    private Gtk.Entry title_entry;
    private Granite.HeaderLabel title_label;
    public Window window { get; construct; }
    public bool title_clickable { get; set; default = false; }

    public HeaderBar (Window win) {
        Object (window: win);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~HeaderBar () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        title_label = new Granite.HeaderLabel ("") {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        title_entry = new Gtk.Entry (); // might delete this

        title_widget = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };
        title_widget.add_named (title_label, "label");
        title_widget.add_named (title_entry, "entry");

        return_button = new Gtk.Button.from_icon_name ("go-previous-symbolic") {
            visible = false
        }; // enables to close infoview of image

        hide_flap = new Gtk.Button.from_icon_name ("view-dual-symbolic") {
            visible = false
        }; // enables to hide infoview flap

        header = new Gtk.HeaderBar () {
            show_title_buttons = true,
            title_widget = title_widget
        };
        header.pack_start (return_button);
        header.pack_end (hide_flap);
        header.set_parent (this);

        var title_click = new Gtk.GestureClick (); // might delete
        title_label.add_controller (title_click);
        title_click.pressed.connect (() => {
            if (title_clickable) {
                title_widget.visible_child_name = "entry";
            }
        });

        title_entry.activate.connect (() => { // might delete
            title_label.label = title_entry.buffer.text;
            title_widget.visible_child_name = "label";
            rename_title ();
        });
    }

    public void set_title (string title) {
        title_label.label = title;
        title_entry.buffer.set_text ((uint8[]) title);
    }

    public string get_title () {
        return title_label.label;
    }

    public signal void rename_title ();
}
