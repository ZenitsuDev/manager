public class Application : Gtk.Application {

    public Application () {
        Object (
            application_id: "com.github.zenitsudev.manager",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Window (this);
        window.present ();
    }
}
