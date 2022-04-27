public class Window : Gtk.ApplicationWindow {
    public HeaderBar headerbar { get; set; }
    public Gtk.Stack main_stack { get; set; }
    public Window (Application app) {
        Object (application: app);
    }

    construct {
        headerbar = new HeaderBar (this);
        headerbar.set_title ("Photo Manager");
        set_titlebar (headerbar);

        var manager_mainpage = new ManagerMainpage (this);

        // might merge manager_mainpage here in the future

        main_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.OVER_LEFT_RIGHT
        };
        main_stack.add_named (manager_mainpage, "manager_mainpage");

        // the main_stack shows either the gallery grid or the image info of opened file

        child = main_stack;

        default_width = 960;
        default_height = 640;

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });
    }
}
