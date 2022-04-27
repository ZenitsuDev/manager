public class FolderSideBar : Gtk.Widget {
    public Gtk.ListBox listbox { get; set; }
    public Gtk.Stack stack { get; construct; }
    public FolderSideBar (Gtk.Stack stack) {
        Object (stack: stack);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~FolderSideBar () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        var listbox = new Gtk.ListBox () {
            vexpand = true
        };
        listbox.bind_model (stack.get_pages (), func);

        var add_button = new Gtk.Button.with_label ("Add Folder") {
            can_focus = false
        };
        add_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            width_request = 150
        };
        box.append (listbox);
        box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        box.append (add_button);

        var mainbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            width_request = 150,
            vexpand = true
        };
        mainbox.append (box);
        mainbox.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        mainbox.set_parent (this);

        listbox.row_selected.connect ((row) => {
            stack.visible_child_name = ((Gtk.Label) row.child.get_last_child ()).label;
        });
    }

    public Gtk.ListBoxRow func (Object item) {
        var stack_page = (Gtk.StackPage) item;
        var icon = new Gtk.Image () {
            pixel_size = 16,
            margin_start = 10,
            margin_end = 10
        };

        switch (stack_page.name) {
            case "Downloads":
                icon.gicon = new ThemedIcon ("folder-download");
                break;
            case "Screenshots":
                icon.gicon = new ThemedIcon ("video-display");
                break;
            default :
                icon.gicon = new ThemedIcon ("folder");
                break;
        }

        var label = new Gtk.Label (stack_page.name);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            height_request = 30
        };
        box.append (icon);
        box.append (label);

        var listboxrow = new Gtk.ListBoxRow () {
            child = box
        };

        return listboxrow;
    }
}
