public class PhotoFolder : Gtk.Widget {
    public Gtk.ScrolledWindow main_container { get; set; }
    public ImageInfoView info_viewer { get; set; }
    public Gtk.FlowBox main_flowbox { get; set; }
    public string path { get; construct; }
    public Window window { get; construct; }
    public PhotoFolder (Window window, string path) {
        Object (
            window: window,
            path: path
        );
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~PhotoFolder () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        main_flowbox = new Gtk.FlowBox () {
            column_spacing = 20,
            row_spacing = 20,
            max_children_per_line = 5,
            hexpand = true,
            valign = Gtk.Align.START,
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20
        };

        // flowbox for responsive children management.

        main_flowbox.child_activated.connect ((child) => {
            var chd = (GridViewImage) child.get_child ();
	        info_viewer = new ImageInfoView (window, chd);
	        window.main_stack.add_named (info_viewer, chd.file.get_basename ());
	        window.main_stack.visible_child_name = chd.file.get_basename ();
	    });

	    // when a flowbox item is activated, the main_stack in Window.vala is called to show
	    // the image in its information page.

        main_container = new Gtk.ScrolledWindow () {
            child = main_flowbox
        };
        main_container.set_parent (this);

        hexpand = true;

        var file = File.new_for_path (path);
        query_children (file); // I might move the query_children inside the construct instead of its own method
    }

    public void query_children (File file) {
        MainLoop loop = new MainLoop ();

	    file.enumerate_children_async.begin ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
	        Priority.DEFAULT, null, (obj, res) => {
		try {
			FileEnumerator enumerator = file.enumerate_children_async.end (res);
			FileInfo info;
			while ((info = enumerator.next_file (null)) != null) {
			    if (info.get_file_type () == FileType.REGULAR) {
			        if ("image" in info.get_content_type ()) { // we filter by images
			            add_image (enumerator.get_child (info));
			        }
			    }
			}
		} catch (Error e) {
			print ("Error: %s\n", e.message);
		}

		loop.quit ();
	    });

	    loop.run ();
    }

    public void add_image (File file) {
        var image = new GridViewImage (file);
        main_flowbox.append (image);
    }
}
