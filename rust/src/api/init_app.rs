use dotenv::dotenv;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    dotenv().ok();
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
