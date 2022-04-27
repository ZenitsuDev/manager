public class ImageInfoView : Gtk.Widget {
    public GridViewImage basis { get; construct; }
    public Window window { get; construct; }
    public Gtk.Adjustment hadjustment { get; set; }
    public Gtk.Adjustment vadjustment { get; set; }
    public Gtk.Image image { get; set; }
    public Gtk.ScrolledWindow image_container { get; set; }
    public int responsive_dimen_size { get; set; default = 550; }

    public signal void control_pressed ();
    public signal void control_released ();

    public ImageInfoView (Window window, GridViewImage image_widget) {
        Object (
            window: window,
            basis: image_widget
        );
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~ImageInfoView () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        calculate_responsive_dimen_size (); // we get the image size from the window size upon initial run
        image = new Gtk.Image.from_paintable (basis.texture) {
            width_request = responsive_dimen_size,
            height_request = responsive_dimen_size,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        image_container = new Gtk.ScrolledWindow () { // I put them inside scrolledwindow to be able to zoom
            hexpand = true,
            vexpand = true,
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20,
            child = image
        };

        hadjustment = image_container.hadjustment; // I might remove these as these are unnecessary assignment
        vadjustment = image_container.vadjustment;

        handle_ctrl_zooming (); // This handles our zooming when the ctrl key is pressed and scrolling happens

        var zoom_slider = new ZoomSlider (this) {
            hexpand = true
        }; // this slider dictates the zoom level by adjusting the image size and moving the scrollbars

        var controls_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true, // this houses the controls. might add in the future
        };
        controls_box.append (zoom_slider);

        var view_and_controls = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true
        };
        view_and_controls.append (image_container);
        view_and_controls.append (controls_box);

        var file_info_sidebar = new ImageAttribView (this) { // incomplete yet but this shows the infos about
            width_request = 250                             // the image shown
        };

        var main_flap = new Adw.Flap () { // to be able to responsibly hide the info when the window shrinks
            transition_type = Adw.FlapTransitionType.SLIDE,
            flap_position = Gtk.PackType.END,
            content = view_and_controls,
            separator = new Gtk.Separator (Gtk.Orientation.VERTICAL),
            flap = file_info_sidebar
        };
        main_flap.set_parent (this);

        this.map.connect (() => { // sets the title as filename, and shows return button, also shows the flap
            window.headerbar.set_title (basis.file.get_basename ());
            window.headerbar.title_clickable = true; // this is necessary in title renaming which I will drop
            window.headerbar.return_button.visible = true;
            window.headerbar.hide_flap.visible = true;
        });

        window.headerbar.hide_flap.clicked.connect (() => {

            // when the flap hides, we want to enlarge the image to make use of the freed space.

            main_flap.reveal_flap = !main_flap.reveal_flap;
            var animation = new Adw.TimedAnimation (image, 0, 100, 500, new Adw.CallbackAnimationTarget (value => {
                if (!main_flap.reveal_flap) {
                    image.width_request = ((int)(responsive_dimen_size * (1 + (value/300))));
        	        image.height_request = ((int)(responsive_dimen_size * (1 + (value/300))));
                } else {
                    image.width_request = ((int)(responsive_dimen_size * (1 + ((100 - value)/300))));
        	        image.height_request = ((int)(responsive_dimen_size * (1 + ((100 - value)/300))));
                }
            }));
            animation.play ();
        });

        window.headerbar.return_button.clicked.connect (() => { // when the return button is clicked,
	        window.main_stack.visible_child_name = "manager_mainpage"; // we return to the gallery.
	        window.headerbar.set_title ("Photo Manager");
	        window.headerbar.title_clickable = false;
	        window.headerbar.return_button.visible = false;
	        window.headerbar.hide_flap.visible = false;
	    });

	    this.unmap.connect (() => {
	        window.main_stack.remove (this); // I remove and destroy this to avoid too much cached?
	        this.destroy ();
	    });

	    window.headerbar.rename_title.connect (() => { // this renames the title and file to desired.
	        try {
		        basis.file.set_display_name (window.headerbar.get_title ());
	        } catch (Error e) {
		        print ("Error: %s\n", e.message);
	        }
	    });

	    window.notify.connect (() => { // when the screen width changes, so does the image size
	        calculate_responsive_dimen_size ();
	        image.width_request = responsive_dimen_size;
        	image.height_request = responsive_dimen_size;
	    });
    }

    public void handle_ctrl_zooming () {
        var ctrl_key = new Gtk.EventControllerKey ();
        image_container.add_controller (ctrl_key);

        // I might combine control_pressed and control_released and just pass a boolean

        ctrl_key.key_pressed.connect ((key) => {
            if (key == Gdk.Key.Control_L || key == Gdk.Key.Control_R) {
                control_pressed ();
            }
            return false;
        });

        ctrl_key.key_released.connect ((key) => {
            if (key == Gdk.Key.Control_L || key == Gdk.Key.Control_R) {
                control_released ();
            }
        });
    }

    public void calculate_responsive_dimen_size () {
        responsive_dimen_size = (int) (350 * ((double) window.get_width () / window.get_height ()));
        // 350 is the magic number for my display size (actually just a guess)
    }
}
