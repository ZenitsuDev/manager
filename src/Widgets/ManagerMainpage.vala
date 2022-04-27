public class ManagerMainpage : Gtk.Widget {
    public Adw.Leaflet main_container { get; set; }
    public Window main_window { get; construct; }
    public ManagerMainpage (Window window) {
        Object (
            main_window: window
        );
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~ManagerMainpage () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    construct {
        var home_path = Environment.get_variable ("HOME");
    	var screenshots_folder = new PhotoFolder (main_window, home_path + "/Pictures/Screenshots/");
    	var downloads_folder = new PhotoFolder (main_window, home_path + "/Downloads/");

    	// No 'All photos' for now for I plan to make the photos separated by date?

        var places_stack = new Gtk.Stack () {
        	transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN
        };

        // This shows the grid of images for the folders sourced

        places_stack.add_named (screenshots_folder, "Screenshots");
        places_stack.add_named (downloads_folder, "Downloads");

        var stack_sidebar = new FolderSideBar (places_stack) {
            width_request = 150
        };

        // I created a custom StackSideBar because it is not possible to add icons on them.

        var main_container = new Adw.Leaflet () {
            transition_type = Adw.LeafletTransitionType.SLIDE,
        };
        main_container.append (stack_sidebar);
        main_container.append (places_stack);
        main_container.visible_child = places_stack;
        main_container.set_parent (this);

        // I used a leaflet for responsiveness, although a flap may suffice?

        hexpand = true;
    }
}
