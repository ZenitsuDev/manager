public class ZoomSlider : Gtk.Widget {
    public Gtk.Scale slider_widget { get; set; }
    public ImageInfoView info_page { get; construct; }
    public ZoomSlider (ImageInfoView info_page) {
        Object (info_page: info_page);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    ~ZoomSlider () {
        while (this.get_last_child () != null) {
            this.get_last_child ().unparent ();
        }
    }

    static double old_x;
    static double old_y;

    construct {
        slider_widget = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 1000, 1) {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            width_request = 200,
            margin_bottom = 10
        };
        slider_widget.set_parent (this); // I used a scale just like the photos app

        var drag = new Gtk.GestureDrag ();
        info_page.image_container.add_controller (drag); // we adjust what part of the image is visible by drag

        drag.drag_update.connect ((x, y) => {

            // We store old x and y values to be able to compare dragging changes and stop the adjustment of view when the dragging stops.

            if (old_x != x && old_y != y) {
            	if (x > 0 && y > 0) {
            	    info_page.hadjustment.value = info_page.hadjustment.value - 10; //10 is personal preference
            	    info_page.vadjustment.value = info_page.vadjustment.value - 10;
            	} else if (x < 0 && y > 0) {
            	    info_page.hadjustment.value = info_page.hadjustment.value + 10;
            	    info_page.vadjustment.value = info_page.vadjustment.value - 10;
            	} else if (x > 0 && y < 0) {
            	    info_page.hadjustment.value = info_page.hadjustment.value - 10;
            	    info_page.vadjustment.value = info_page.vadjustment.value + 10;
            	} else {
            	    info_page.hadjustment.value = info_page.hadjustment.value + 10;
            	    info_page.vadjustment.value = info_page.vadjustment.value + 10;
            	}
            	old_x = x;
                old_y = y;
            }
        });

        slider_widget.change_value.connect ((type, val) => {

            // when the slider is dragged, we zoom by enlarging the image with the responsive dimension size and
            // scaling it with the value, then we adjust the scrollbars to show the middle (unfixed yet)

        	info_page.image.width_request = ((int)(info_page.responsive_dimen_size * (1 + (Math.ceil(val)/100))));
        	info_page.image.height_request = ((int)(info_page.responsive_dimen_size * (1 + (Math.ceil(val)/100))));
        	info_page.hadjustment.value = info_page.hadjustment.get_upper () / 2;
        	info_page.vadjustment.value = info_page.vadjustment.get_upper () / 2;

        	info_page.image_container.grab_focus (); // we grab the focus from the slider to be able to receive the control zoom
        	return false;
        });

        var scroller = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.BOTH_AXES);
        // if control is pressed, we only want one scroll controller and remove it when we release;
        info_page.control_pressed.connect (() => {
            if (scroller.widget == null) {
                info_page.image_container.add_controller (scroller);
            }
        });
        info_page.control_released.connect (() => {
            if (scroller.widget != null) {
                info_page.image_container.remove_controller (scroller);
            }
        });

        scroller.scroll.connect ((x, y) => {
            if (y > 0) { // we move the slider according to the scroll direction we get
                slider_widget.move_slider (Gtk.ScrollType.STEP_LEFT);
            } else {
                slider_widget.move_slider (Gtk.ScrollType.STEP_RIGHT);
            }

            return false;
        });
    }
}
